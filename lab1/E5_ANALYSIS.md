# E5 : Trois surfaces d’entrée

Cette analyse porte sur le programme historique `Labsetup/catall.c`, utilisé
par les scripts T4 et T5. Le programme construit `/bin/cat <argv[1]>` avec
`sprintf()`, puis transmet la chaîne obtenue à `system()`, qui invoque
`/bin/sh -c`.

## 1. Entrée utilisateur : `argv[1]`

**Hypothèse implicite :** `argv[1]` est un simple nom de fichier et ne peut
pas modifier la structure de la commande.

Le programme ne met pas l’argument entre guillemets et ne l’échappe pas avant
de l’insérer dans la commande shell. La syntaxe du shell contenue dans
l’argument, notamment `;`, `&&`, `|`, une substitution de commande ou un saut
de ligne, peut donc modifier les commandes exécutées. C’est la cause première
illustrée par T4 et les exemples d’injection du corpus.

## 2. Environnement : `PATH` et `IFS`

**Hypothèse implicite :** l’environnement hérité peut être utilisé sans risque
par le shell et ne peut ni influencer la résolution des commandes ni modifier
l’interprétation.

`system()` hérite de l’environnement de son appelant. La commande `/bin/cat`
prévue utilise un chemin absolu : modifier `PATH` ne remplace donc pas cette
commande. En revanche, une commande injectée sous un nom simple, comme `id`,
est résolue à l’aide du `PATH` hérité ; T5 illustre ce cas.

`catall.c` ne réinitialise pas `IFS`, mais son effet dépend du shell et de la
manière dont cette variable est utilisée. Nous ne présentons pas `IFS` comme
une exploitation réussie : lors de l’analyse de cette chaîne de commande
littérale, `IFS` ne remplace généralement pas les séparateurs syntaxiques du
shell.

## 3. Liaison dynamique : `LD_PRELOAD` et `LD_LIBRARY_PATH`

**Hypothèse implicite :** le programme ne valide pas explicitement les
variables du chargeur ; il dépend du comportement du système en exécution
privilégiée pour empêcher le chargement de bibliothèques non fiables.

Lorsqu’un utilisateur non privilégié exécute un binaire Set-UID appartenant à
root, Linux active le mode d’exécution sécurisée. Dans ce mode, le chargeur
dynamique ignore ou restreint des variables comme `LD_PRELOAD` et
`LD_LIBRARY_PATH`. T6 vérifie cette limite : le constructeur de la
bibliothèque préchargée s’exécute avec un binaire témoin sans Set-UID, mais ne
devrait pas s’exécuter avec `catall` Set-UID. Cette protection vient du
chargeur, et non d’une correction de `catall.c` ; elle n’empêche ni l’injection
shell ni le détournement par `PATH`.

Les scripts T4/T5 remplacent temporairement la cible de `/bin/sh` par zsh, car
certaines implémentations de `/bin/sh` abandonnent les privilèges Set-UID.
Ce comportement propre au shell n’accorde pas le privilège initial : le
noyau effectue la transition Set-UID lorsqu’il exécute le programme
appartenant à root.