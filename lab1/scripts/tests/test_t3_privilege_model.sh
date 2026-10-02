#!/bin/bash
# E4 / T3 - Distinction UID reel / effectif / sauvegarde
#
# Compile show_ids.c, l'installe comme binaire Set-UID root avec le
# meme traitement que catall (chown root, chmod 4755), puis l'execute
# en tant qu'utilisateur non privilegie pour observer l'elevation de
# l'UID effectif imposee par le noyau.
set -e

SRC=../../Labsetup/show_ids.c
BIN=./show_ids

if [ ! -f "$SRC" ]; then
  echo "ERREUR: $SRC introuvable. Executer ce script depuis le dossier Labsetup."
  exit 1
fi

echo "=== Compilation de show_ids ==="
gcc "$SRC" -o "$BIN"

echo "=== Installation Set-UID root (meme traitement que catall) ==="
sudo chown root:root "$BIN"
sudo chmod 4755 "$BIN"
ls -l "$BIN"

echo
echo "=== Utilisateur invoquant ==="
whoami

echo
echo "=== UID reel / effectif / sauvegarde observes ==="
"$BIN"

echo
echo "Interpretation : l'UID reel correspond a l'utilisateur qui a lance"
echo "le programme; l'UID effectif est celui du proprietaire du fichier"
echo "(root), impose par le noyau au moment de l'execve() a cause du bit"
echo "Set-UID; l'UID sauvegarde permet au processus de retrouver ce"
echo "privilege plus tard s'il l'abandonne temporairement. Ce meme"
echo "mecanisme s'applique a catall, qui recoit le meme traitement"
echo "(chown root + chmod 4755)."