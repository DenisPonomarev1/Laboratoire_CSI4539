#!/bin/bash
# T7 - Correction inerte
#
# Rejoue les memes charges utiles que T4 (injection) et T5 (detournement
# PATH) contre catall_fixed, et confirme qu'elles n'ont plus aucun effet.
# Aucun changement de /bin/sh n'est necessaire ici : catall_fixed n'invoque
# plus jamais de shell (execve() remplace system()), donc le comportement
# de dash/zsh est hors sujet pour ce test.
set -e

LAB_DIR="$(cd "$(dirname "$0")/../../Labsetup" && pwd)"
cd "$LAB_DIR"

gcc catall_fixed.c -o catall_fixed
sudo chown root:root catall_fixed
sudo chmod 4755 catall_fixed

echo "=== Permissions de catall_fixed ==="
ls -l ./catall_fixed

MARKER4=/tmp/pwned_t4.txt
MARKER5=/tmp/pwned_t5.txt
sudo rm -f "$MARKER4" "$MARKER5"

echo
echo "=== Rejeu de la charge utile T4 (injection de commande) ==="
PAYLOAD4="x; /usr/bin/id > $MARKER4; echo injection-reussie #"
echo "Charge utile : $PAYLOAD4"
./catall_fixed "$PAYLOAD4" || true

if [ -f "$MARKER4" ]; then
    echo "ECHEC DE LA CORRECTION : $MARKER4 a ete cree !"
    cat "$MARKER4"
else
    echo "OK : $MARKER4 n'existe pas. L'injection est inerte."
    echo "     execve() a transmis toute la chaine comme UN SEUL nom de"
    echo "     fichier a /bin/cat, qui a simplement echoue (fichier"
    echo "     introuvable) sans jamais invoquer de shell."
fi

echo
echo "=== Rejeu de la charge utile T5 (detournement PATH) ==="
EVIL_DIR=/tmp/evilbin
export PATH="$EVIL_DIR:$PATH"
PAYLOAD5="x; id; #"
echo "PATH utilise : $PATH"
echo "Charge utile : $PAYLOAD5"
./catall_fixed "$PAYLOAD5" || true

if [ -f "$MARKER5" ]; then
    echo "ECHEC DE LA CORRECTION : $MARKER5 a ete cree !"
    cat "$MARKER5"
else
    echo "OK : $MARKER5 n'existe pas. Le detournement PATH est inerte."
    echo "     catall_fixed n'utilise plus l'environnement herite ni un"
    echo "     shell pour resoudre des noms de commande ; PATH n'a donc"
    echo "     plus aucune influence sur son comportement."
fi