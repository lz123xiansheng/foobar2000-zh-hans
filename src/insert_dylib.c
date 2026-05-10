// @ai-generated: claude-sonnet-4
// insert_dylib.c - Minimal Mach-O dylib injector
// Adds LC_LOAD_DYLIB load command to a Mach-O binary
// Usage: ./insert_dylib <dylib_path> <binary_path> [output_path]

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <mach-o/loader.h>
#include <mach-o/fat.h>

#define SWAP32(x) (x)

static void usage(void) {
    fprintf(stderr, "Usage: insert_dylib <dylib_path> <binary_path> [output_path]\n");
    fprintf(stderr, "  Adds LC_LOAD_DYLIB load command to Mach-O binary\n");
    exit(1);
}

static size_t align(size_t n, size_t alignment) {
    return (n + alignment - 1) & ~(alignment - 1);
}

// Process a single architecture slice
static int process_slice(FILE *f, size_t offset, const char *dylib_path) {
    fseek(f, offset, SEEK_SET);
    
    struct mach_header_64 mh;
    if (fread(&mh, sizeof(mh), 1, f) != 1) return -1;
    
    if (mh.magic != MH_MAGIC_64) {
        fprintf(stderr, "  Not a 64-bit Mach-O slice, skipping\n");
        return 0;
    }
    
    size_t commands_offset = offset + sizeof(struct mach_header_64);
    
    // Find LC_CODE_SIGNATURE and remove it
    int found_codesig = 0;
    uint32_t codesig_dataoff = 0, codesig_datasize = 0, codesig_cmdsize = 0;
    
    fseek(f, commands_offset, SEEK_SET);
    for (uint32_t i = 0; i < mh.ncmds; i++) {
        struct load_command lc;
        fread(&lc, sizeof(lc), 1, f);
        if (lc.cmd == LC_CODE_SIGNATURE) {
            fseek(f, -((long)sizeof(lc)), SEEK_CUR);
            struct linkedit_data_command ldc;
            fread(&ldc, sizeof(ldc), 1, f);
            codesig_dataoff = ldc.dataoff;
            codesig_datasize = ldc.datasize;
            codesig_cmdsize = ldc.cmdsize;
            found_codesig = 1;
            printf("  Found LC_CODE_SIGNATURE at offset %u, size %u\n", codesig_dataoff, codesig_datasize);
            
            // Zero out the load command
            fseek(f, -((long)sizeof(ldc)), SEEK_CUR);
            char *zero = calloc(codesig_cmdsize, 1);
            fwrite(zero, codesig_cmdsize, 1, f);
            free(zero);
            break;
        }
        fseek(f, lc.cmdsize - sizeof(lc), SEEK_CUR);
    }
    
    if (!found_codesig) {
        printf("  No LC_CODE_SIGNATURE found (already removed or unsigned)\n");
    }
    
    // Now insert our LC_LOAD_DYLIB
    size_t dylib_path_len = strlen(dylib_path);
    size_t dylib_path_size = align(dylib_path_len + 1, 8);
    uint32_t cmdsize = (uint32_t)(sizeof(struct dylib_command) + dylib_path_size);
    
    // Adjust header (ncmds decremented if codesig removed, then incremented for new cmd)
    if (found_codesig) mh.ncmds--;
    
    // Write new command at the end of load commands
    size_t new_cmd_offset = commands_offset + mh.sizeofcmds - (found_codesig ? codesig_cmdsize : 0);
    
    struct dylib_command dc;
    memset(&dc, 0, sizeof(dc));
    dc.cmd = LC_LOAD_DYLIB;
    dc.cmdsize = cmdsize;
    dc.dylib.name.offset = sizeof(struct dylib_command);
    dc.dylib.timestamp = 2;
    dc.dylib.current_version = 0;
    dc.dylib.compatibility_version = 0;
    
    char *padded_path = calloc(dylib_path_size, 1);
    memcpy(padded_path, dylib_path, dylib_path_len);
    
    fseek(f, new_cmd_offset, SEEK_SET);
    fwrite(&dc, sizeof(dc), 1, f);
    fwrite(padded_path, dylib_path_size, 1, f);
    free(padded_path);
    
    // Update header
    mh.ncmds++;
    mh.sizeofcmds = mh.sizeofcmds - (found_codesig ? codesig_cmdsize : 0) + cmdsize;
    
    fseek(f, offset, SEEK_SET);
    fwrite(&mh, sizeof(mh), 1, f);
    
    printf("  Added LC_LOAD_DYLIB: %s (cmdsize=%u)\n", dylib_path, cmdsize);
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc < 3) usage();
    
    const char *dylib_path = argv[1];
    const char *binary_path = argv[2];
    const char *output_path = argv[3] ? argv[3] : binary_path;
    
    printf("insert_dylib: %s -> %s\n", dylib_path, binary_path);
    printf("Output: %s\n", output_path);
    
    // Read input binary
    FILE *in = fopen(binary_path, "rb");
    if (!in) {
        perror("fopen input");
        return 1;
    }
    
    fseek(in, 0, SEEK_END);
    size_t size = ftell(in);
    fseek(in, 0, SEEK_SET);
    char *data = malloc(size);
    fread(data, 1, size, in);
    fclose(in);
    
    // Check for fat binary
    uint32_t magic = *(uint32_t*)data;
    
    if (magic == FAT_MAGIC || magic == FAT_CIGAM) {
        printf("Fat binary detected\n");
        struct fat_header *fh = (struct fat_header*)data;
        uint32_t narch = OSSwapBigToHostInt32(fh->nfat_arch);
        printf("  %u architectures\n", narch);
        
        struct fat_arch *archs = (struct fat_arch*)(data + sizeof(struct fat_header));
        
        for (uint32_t i = 0; i < narch; i++) {
            uint32_t arch_offset = OSSwapBigToHostInt32(archs[i].offset);
            cpu_type_t cpu = OSSwapBigToHostInt32(archs[i].cputype);
            printf("  Arch %u: cpu=%u offset=%u\n", i, cpu, arch_offset);
        }
        
        // Write fat binary to output
        FILE *out = fopen(output_path, "wb");
        if (!out) {
            perror("fopen output");
            free(data);
            return 1;
        }
        fwrite(data, 1, size, out);
        fclose(out);
        
        // Now modify each slice in the output
        FILE *mod = fopen(output_path, "r+b");
        if (!mod) {
            perror("fopen output for modification");
            free(data);
            return 1;
        }
        
        for (uint32_t i = 0; i < narch; i++) {
            uint32_t arch_offset = OSSwapBigToHostInt32(archs[i].offset);
            process_slice(mod, arch_offset, dylib_path);
        }
        fclose(mod);
        
    } else if (magic == MH_MAGIC_64) {
        printf("Thin 64-bit binary detected\n");
        
        FILE *out = fopen(output_path, "wb");
        if (!out) { perror("fopen output"); free(data); return 1; }
        fwrite(data, 1, size, out);
        fclose(out);
        
        FILE *mod = fopen(output_path, "r+b");
        process_slice(mod, 0, dylib_path);
        fclose(mod);
    } else {
        fprintf(stderr, "Unknown binary format (magic: 0x%x)\n", magic);
        free(data);
        return 1;
    }
    
    free(data);
    
    // Verify with otool
    printf("\nVerifying with otool:\n");
    char cmd[1024];
    snprintf(cmd, sizeof(cmd), "otool -L '%s' | grep -i fb2k || echo '(checking...)'; otool -L '%s' | tail -5", output_path, output_path);
    system(cmd);
    
    printf("\nDone! Binary patched at: %s\n", output_path);
    return 0;
}