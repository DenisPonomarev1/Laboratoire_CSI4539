#!/bin/bash
# T8 - Abandon de privilege
#
# Compile et installe catall_fixed_debug comme Set-UID root (meme
# traitement que catall_fixed). Execute-le contre un fichier que seul
# root peut lire, afin de :
#   1. montrer l'UID effectif = 0 avant l'abandon,
#   2. montrer l'UID effectif retombe a l'UID reel apres setresuid(),
#   3. montrer qu'une tentative de re-elevation (seteuid(0)) echoue,
#   4. confirmer que le fichier protege est tout de meme affiche,
#      prouvant que la fonctionnalite du programme reste intacte.
set -e

LAB_DIR="$(cd "$(dirname "$0")/../../Labsetup" && pwd)"
cd "$LAB_DIR"

echo "=== Compilation de catall_fixed_e8 ==="
gcc catall_fixed_e8.c -o catall_fixed_e8
sudo chown root:root catall_fixed_e8
sudo chmod 4755 catall_fixed_e8
ls -l catall_fixed_e8

echo
echo "=== Preparation d'un fichier protege (lisible par root seulement) ==="
sudo bash -c 'echo "contenu secret root uniquement" > /tmp/t8_protected.txt'
sudo chown root:root /tmp/t8_protected.txt
sudo chmod 600 /tmp/t8_protected.txt
ls -l /tmp/t8_protected.txt

echo
echo "=== Utilisateur invoquant ==="
whoami

echo
echo "=== Execution ==="
./catall_fixed_e8 /tmp/t8_protected.txt