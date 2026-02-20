#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// R type instruction
unsigned int encodeR(int funct7, int rs2, int rs1, int funct3, int rd, int opcode)
{
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode;
}

// I type instruction
unsigned int encodeI(int imm, int rs1, int funct3, int rd, int opcode)
{
    imm &= 0xFFF; // 12-bit
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode;
}

// S type instruction
unsigned int encodeS(int imm, int rs2, int rs1, int funct3, int opcode)
{
    int imm11_5 = (imm >> 5) & 0x7F;
    int imm4_0 = imm & 0x1F;
    return (imm11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm4_0 << 7) | opcode;
}

// B type instruction
unsigned int encodeB(int imm, int rs2, int rs1, int funct3, int opcode)
{
    int imm12 = (imm >> 12) & 0x1;
    int imm10_5 = (imm >> 5) & 0x3F;
    int imm4_1 = (imm >> 1) & 0xF;
    int imm11 = (imm >> 11) & 0x1;
    return (imm12 << 31) | (imm11 << 7) | (imm10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm4_1 << 8) | opcode;
}

// J type instruction
unsigned int encodeJ(int imm, int rd, int opcode)
{
    int imm20 = (imm >> 20) & 0x1;
    int imm10_1 = (imm >> 1) & 0x3FF;
    int imm11 = (imm >> 11) & 0x1;
    int imm19_12 = (imm >> 12) & 0xFF;
    return (imm20 << 31) | (imm19_12 << 12) | (imm11 << 20) | (imm10_1 << 21) | (rd << 7) | opcode;
}

// Instruction definition structure
typedef struct
{
    const char *name;
    int type; // 0=R, 1=I, 2=S, 3=B, 4=J
    int funct7;
    int funct3;
    int opcode;
} Instruction;

// Instruction lookup table
Instruction instructions[] = {
    // R type instructions
    {"add", 0, 0x00, 0x0, 0x33},
    {"sub", 0, 0x20, 0x0, 0x33},
    {"sll", 0, 0x00, 0x1, 0x33},
    {"slt", 0, 0x00, 0x2, 0x33},
    {"sltu", 0, 0x00, 0x3, 0x33},
    {"xor", 0, 0x00, 0x4, 0x33},
    {"srl", 0, 0x00, 0x5, 0x33},
    {"sra", 0, 0x20, 0x5, 0x33},
    {"or", 0, 0x00, 0x6, 0x33},
    {"and", 0, 0x00, 0x7, 0x33},
    // I type instructions
    {"addi", 1, 0, 0x0, 0x13},
    {"slli", 1, 0, 0x1, 0x13},
    {"slti", 1, 0, 0x2, 0x13},
    {"sltui", 1, 0, 0x3, 0x13},
    {"xori", 1, 0, 0x4, 0x13},
    {"srli", 1, 0, 0x5, 0x13},
    {"srai", 1, 0, 0x5, 0x13},
    {"ori", 1, 0, 0x6, 0x13},
    {"andi", 1, 0, 0x7, 0x13},
    {"ld", 1, 0, 0x3, 0x03},
    {"jalr", 1, 0, 0x0, 0x67},
    // S type instructions
    {"sd", 2, 0, 0x3, 0x23},
    // B type instructions
    {"beq", 3, 0, 0x0, 0x63},
    // J type instructions
    {"jal", 4, 0, 0x0, 0x6f},
    // Null type
    {NULL, -1, 0, 0, 0}};

int regNum(const char *s)
{
    if (s[0] == 'x')
        return atoi(s + 1);
    return -1;
}

Instruction *findInstruction(const char *name)
{
    for (int i = 0; instructions[i].name != NULL; i++)
        if (!strcmp(instructions[i].name, name))
            return &instructions[i];
    return NULL;
}

void dumpHexToFile(unsigned int code, FILE *fout)
{
    // Big Endian format - two bytes per line
    for (int i = 3; i >= 0; i--)
        fprintf(fout, "%02X\n", (code >> (i * 8)) & 0xFF);
}

int main(int argc, char **argv)
{
    char line[100], rdstr[10], rs1str[10], rs2str[10];
    int rd, rs1, rs2, imm;

    if (argc <= 3)
    {
        printf("No file to process provided\n");
        printf("Usage: asm.exe <input_file> -o <output_file>\n");
        return 1;
    }

    FILE *fin = fopen(argv[1], "r"); // Open the input file
    if (!fin)
    {
        perror("File open failed");
        return 1;
    }

    FILE *fout = fopen(argv[3], "w");
    if (!fout)
    {
        perror("File open failed");
        return 1;
    }

    while (fgets(line, sizeof(line), fin) != NULL)
    {
        unsigned int code = 0;
        char instname[20];

        // Remove newline character
        line[strcspn(line, "\r\n")] = 0;

        // Strip commas to support standard RISC-V assembly notation (e.g. jalr x1, 0(x2))
        for (int i = 0; line[i]; i++)
            if (line[i] == ',')
                line[i] = ' ';

        // Ignore gaps and comments
        if ((strlen(line) == 0) || (line[0] == '#'))
            continue;

        // Extract instruction name
        if (sscanf(line, "%s", instname) != 1)
            continue;

        // Look up instruction in table
        Instruction *inst = findInstruction(instname);
        if (inst == NULL)
        {
            printf("Skipping unsupported instruction: %s\n", line);
            continue;
        }

        // Parse operands and encode based on instruction type
        switch (inst->type)
        {
        case 0: // R-type: <funct> rd rs1 rs2
            if (sscanf(line, "%s %s %s %s", instname, rdstr, rs1str, rs2str) == 4)
            {
                rd = regNum(rdstr);
                rs1 = regNum(rs1str);
                rs2 = regNum(rs2str);
                code = encodeR(inst->funct7, rs2, rs1, inst->funct3, rd, inst->opcode);
            }
            break;

        case 1: // I-type: <funct> rd rs1 imm OR <funct> rd imm(rs1)
            // Try format: "addi rd rs1 imm"
            if (sscanf(line, "%s %s %s %d", instname, rdstr, rs1str, &imm) == 4)
            {
                rd = regNum(rdstr);
                rs1 = regNum(rs1str);
                code = encodeI(imm, rs1, inst->funct3, rd, inst->opcode);
            }
            // Try format: "ld rd imm(rs1)"
            else if (sscanf(line, "%s %s %d(%[^)])", instname, rdstr, &imm, rs1str) == 4)
            {
                rd = regNum(rdstr);
                rs1 = regNum(rs1str);
                code = encodeI(imm, rs1, inst->funct3, rd, inst->opcode);
            }
            break;

        case 2: // S-type: <funct> rs2 imm(rs1)
            if (sscanf(line, "%s %s %d(%[^)])", instname, rs2str, &imm, rs1str) == 4)
            {
                rs2 = regNum(rs2str);
                rs1 = regNum(rs1str);
                code = encodeS(imm, rs2, rs1, inst->funct3, inst->opcode);
            }
            break;

        case 3: // B-type: <funct> rs1 rs2 imm
            if (sscanf(line, "%s %s %s %d", instname, rs1str, rs2str, &imm) == 4)
            {
                rs1 = regNum(rs1str);
                rs2 = regNum(rs2str);
                code = encodeB(imm, rs2, rs1, inst->funct3, inst->opcode);
            }
            break;

        case 4: // J-type: <funct> rd imm
            if (sscanf(line, "%s %s %d", instname, rdstr, &imm) == 3)
            {
                rd = regNum(rdstr);
                code = encodeJ(imm, rd, inst->opcode);
            }
            break;

        default:
            printf("Unknown instruction type\n");
            continue;
        }

        if (code != 0 || inst->type == 1)
        { // code != 0 is a heuristic; J-type could be 0
            dumpHexToFile(code, fout);
        }
    }
    fclose(fin);
    fclose(fout);
    printf("Hex output written to ");
    printf(argv[3]);
    printf("\n");
    return 0;
}
