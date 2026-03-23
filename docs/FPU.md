# Designing an FPU

## IEEE 754: Standard for Floating Point Numbers

The Floating Point format attempt to increase the range of representable within a fixed number of bits. It works similar to scientific notation, where there is a mantissa part which determines the precision, an exponent part which determines the magnitude and a sign bit. However the limited bit length leads to a few challenges, which need to be addressed. 

**A single precision floating point (FP32) number has 32 bits, and has the following parts:**

\* (insert image) *

Bias: 127

**A double precision floating point (FP64) number has 64 bits, and has the following parts:**

\* (insert image) *

Bias: 1023

In the decimal system, the integer part of a number written in scientific notation can take values between 1-9. But in a binary system, the intger part is guarranteed to be 1. Thus the leading 1 is omitted when writing the mantissa, to save space.

### Special Numbers:

\* insert table with naN, infinity, zero, subnormal and normal *





