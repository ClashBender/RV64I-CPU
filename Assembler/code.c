#include <stdio.h>
#include <string.h>
#include <stdlib.h>
// R type instruction
unsigned int encodeR(int funct7, int rs2, int rs1, int funct3, int rd, int opcode) {
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode;
}
// I type instruction
unsigned int encodeI(int imm, int rs1, int funct3, int rd, int opcode) {
    imm &= 0xFFF; // 12-bit
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode;
}
// S type instruction
unsigned int encodeS(int imm, int rs2, int rs1, int funct3, int opcode) {
    int imm11_5 = (imm >> 5) & 0x7F;
    int imm4_0  = imm & 0x1F;
    return (imm11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm4_0 << 7) | opcode;
}
// B type instruction
unsigned int encodeB(int imm, int rs2, int rs1, int funct3, int opcode) {
    int imm12   = (imm >> 12) & 0x1;
    int imm10_5 = (imm >> 5) & 0x3F;
    int imm4_1  = (imm >> 1) & 0xF;
    int imm11   = (imm >> 11) & 0x1;
    return (imm12 << 31) | (imm11 << 7) | (imm10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm4_1 << 8) | opcode;
}

int regNum(const char* s) {
    if (s[0] == 'x') return atoi(s+1);
    return -1;
}

void dumpHexToFile(unsigned int code, FILE *fout) {
    // Write 4 lines, 1 byte (2 hex digits) per line, MSB first
    for (int i = 3; i >= 0; i--) {
        fprintf(fout, "%02X\n", (code >> (i*8)) & 0xFF);
    }
}

int main(int argc, char** argv) {
    char line[100], rdstr[10], rs1str[10], rs2str[10];
    int rd, rs1, rs2, imm;

    if(argc <= 3){
        printf("No file to process provided\n");
        printf("Usage: asm.exe <input_file> -o <output_file>\n");
        return 1;
    }

    FILE *fin = fopen(argv[1], "r");   // Open the input file
    if (!fin) { perror("File open failed"); return 1; }

    FILE *fout = fopen(argv[3], "w");
    if (!fout) { perror("File open failed"); return 1; }

    while (fgets(line, sizeof(line), fin) != NULL) {
        unsigned int code = 0;
       
        // Remove newline character
        line[strcspn(line, "\r\n")] = 0;
        if(strlen(line) == 0) continue;
        if(line[0] == '#') continue;
        if (sscanf(line, "add %s %s %s", rdstr, rs1str, rs2str) == 3) {
            rd = regNum(rdstr); rs1 = regNum(rs1str); rs2 = regNum(rs2str);
            code = encodeR(0x00, rs2, rs1, 0x0, rd, 0x33);
        }
        else if (sscanf(line, "sub %s %s %s", rdstr, rs1str, rs2str) == 3) {
            rd = regNum(rdstr); rs1 = regNum(rs1str); rs2 = regNum(rs2str);
            code = encodeR(0x20, rs2, rs1, 0x0, rd, 0x33);
        }
        else if (sscanf(line, "and %s %s %s", rdstr, rs1str, rs2str) == 3) {
            rd = regNum(rdstr); rs1 = regNum(rs1str); rs2 = regNum(rs2str);
            code = encodeR(0x00, rs2, rs1, 0x7, rd, 0x33);
        }
        else if (sscanf(line, "or %s %s %s", rdstr, rs1str, rs2str) == 3) {
            rd = regNum(rdstr); rs1 = regNum(rs1str); rs2 = regNum(rs2str);
            code = encodeR(0x00, rs2, rs1, 0x6, rd, 0x33);
        }
        else if (sscanf(line, "addi %s %s %d", rdstr, rs1str, &imm) == 3) {
            rd = regNum(rdstr); rs1 = regNum(rs1str);
            code = encodeI(imm, rs1, 0x0, rd, 0x13);
        }
        else if (sscanf(line, "ld %s %d(%s)", rdstr, &imm, rs1str) == 3) {
            rd = regNum(rdstr); rs1 = regNum(rs1str);
            code = encodeI(imm, rs1, 0x3, rd, 0x03);
        }
        else if (sscanf(line, "sd %s %d(%s)", rs2str, &imm, rs1str) == 3) {
            rs2 = regNum(rs2str); rs1 = regNum(rs1str);
            code = encodeS(imm, rs2, rs1, 0x3, 0x23);
        }
        else if (sscanf(line, "beq %s %s %d", rs1str, rs2str, &imm) == 3) {
            rs1 = regNum(rs1str); rs2 = regNum(rs2str);
            code = encodeB(imm, rs2, rs1, 0x0, 0x63);
        }
        else {
            printf("Skipping unsupported instruction: %s\n", line);
            continue;
        }

        dumpHexToFile(code, fout);
    }
    fclose(fin);
    fclose(fout);
    printf("Hex output written to ");
    printf(argv[3]);
    printf("\n");
    return 0;
}
