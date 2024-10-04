# VU MIF PS komiuterių architektūros darbai (1 kursas)

*english below ↓↓↓*


Čia yra sukeltos užduotys padarytos per komputerių architektūros pratybas.

Užduotys darytos turbo asembleriu (TASM).

Programų paleidimo žingsiniai(įsijungus dosbox):
1. tasm xxx.asm
1. tlink /v xxx
1. xxx

(xxx - programos pavadinimas)

---
### 1_uzd.asm
Programa, kuri atspausdina įvestoje simbolių eilutėje rastų mažųjų raidžių skaičių. 

Paleidimao pvz.: 1_uzd

(paspaudus enter rašomi visokie simboliai): abs 54d2 ASD

---
### 2uzd.asm 
Trečiame paleidimo žingsnyje reikia įvesti 3 perametrus: failo pavadinimą ir du skaičius. Viskas turi būti atskirta vienu tarpu. 

Paleidimas atrodytų taip:  xxx duom.txt 2 3

Programa sukeičia skaičiais nurodytas eilutes esančias duomenų faile.

Rezultatai išvedami faile rezults.txt 

---
### 3uzd.asm
Trečiame paleidimo žingsnyje reikia įvesti 2 perametrus, kurie yra failų vardai.

Paleidimo pvz.: xxx duom.txt rezults.txt

Programa yra dalinis disasembleris, kuris apdoroja komandas: mov, out, not, rcr, xlat.

*Deja, programa neapdoroja visų įmanomų mov variantų.*

---
#### Failas DIS1.com

Tai pratybų dėstytojo duotas failas, kuriame yra visų mov funkcijų variantų vykdomieji kodai.


----
# English

Here you can find my work for computer architecture lectures for SE course in Vilnius University faculty of Mathematics and Informatics.

Programs were written using Turbo Assembler (TASM).

Steps for running the programs (when dosbox is open):
1. tasm xxx.asm
2. tlink /v xxx
3. xxx

(where xxx is the name of the program)

---
### 1_uzd.asm
This program counts the amount of lower case letters in an input and prints this number. 

Exampele of running this program: 1_uzd

(after pressing enter you may enter symbols): abs 54d2ASD


---
### 2uzd.asm

In the third step for running the program there is a need to write 3 parameters: file name and 2 numbers. Everything needs to be separated by a space.

The command for running this program should look something like this: xxx data.txt 2 3

The program switches two lines, which were specified by the user when running the program, present in the input file.

Results are outtputed in rezults.txt

---
### 3uzd.asm

In the third step for running the program there is a need to write 2 parameters which are the file names.

Example of running the program: xxx data.txt results.txt

This program is a partial disassembler. It can recognise these commands: mov, out, not, rcr, xlat.

*Sadly, not all mov variations are recognized.*

---
### File DIS1.COM

It's a file given by my practical lesson lecturer. It contains all variations for the command mov.
