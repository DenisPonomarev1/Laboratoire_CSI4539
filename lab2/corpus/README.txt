CEG 4799 / CSI 4539 - Laboratoire 2 - corpus d'entrees memoire
================================================================
Legue au projet final (section 1 / E8 du labo 2). Chaque fichier ci-dessous
est une entree malveillante (payload) rejouable contre les binaires
vulnerables du depot (stack-L1 ou retlib), et non un programme ou un binaire
attaque.


01_overflow_l1.bin
------------------
Source      : exploit.py
Taille      : 517 octets
Contenu     : NOP sled (0x90) + shellcode execve("/bin//sh") 32 bits, adresse
              de retour ecrite a l'offset 112
Cible       : stack-L1 (BUF_SIZE=100)
Propriete violee : domaine de longueur (length(input) <= 100),
                    invariant du tampon
Effet       : adresse de retour ecrasee, saut vers le shellcode injecte,
              interpreteur root obtenu


02_overflow_dash.bin
---------------------
Source      : exploit_l1_setuid.py
Taille      : 517 octets
Contenu     : identique a 01, avec setuid(0) et setgid(0) ajoutes avant le
              shellocode principal
Cible       : stack-L1, avec /bin/sh pointant vers dash (protection active)
Propriete violee : meme que 01
Effet       : la protection de dash est contournee car le shellcode abaisse
              lui-meme ses privileges avant d'invoquer le shell


03_overflow_aslr.bin
---------------------
Source      : exploit_aslr.py
Taille      : 517 octets
Contenu     : grande zone NOP (depart a l'offset 480) + shellcode, adresse de
              retour fournie en parametre (devinee par force brute)
Cible       : stack-L1, avec ASLR actif (randomize_va_space=2)
Propriete violee : domaine de longueur
Effet       : utilise avec brute-force-aslr.sh pour deviner une adresse de
              retour valide malgre l'ASLR


04_overflow_l2.bin
-------------------
Source      : exploit_l2.py
Taille      : 517 octets
Contenu     : NOP sled, shellcode place tardivement dans le payload, meme
              adresse de retour ecrite a plusieurs offsets consecutifs
              (112 a 212)
Cible       : stack-L2 (taille de tampon inconnue, plage 100-200 octets)
Propriete violee : domaine de longueur, invariant du tampon
Effet       : une seule charge fonctionne quelle que soit la taille exacte
              du tampon dans la plage visee


05_overflow_l3.bin
-------------------
Source      : exploit_l3.py
Taille      : 517 octets
Contenu     : shellcode execve 64 bits (sans octet nul), adresse de retour
              64 bits ecrite a l'offset 208
Cible       : stack-L3 (binaire 64 bits)
Propriete violee : domaine de longueur, borne d'index
Effet       : demontre la gestion des octets nuls dans une adresse 64 bits
              avec strcpy()


06_retlibc_valid.bin
----------------------
Source      : exploit_script.py (variante return-to-libc pour retlib.c)
Contenu     : offsets X/Y/Z pointant vers system(), exit() et la chaine
              "/bin/sh" (variable d'environnement)
Cible       : retlib (pile non executable active, StackGuard desactive)
Propriete violee : integrite de l'adresse de retour
Effet       : system("/bin/sh") execute sans injecter de code, contourne
              la pile non executable


07_retlibc_badaddr.bin
-------------------------
Source      : copie de 06, adresse de retour remplacee par 0x41414141
Cible       : retlib
Propriete violee : integrite de l'adresse de retour
Effet       : cas de test negatif. Confirme que l'ecrasement atteint bien
              l'emplacement de l'adresse de retour (plantage apres l'obtention
              du shell privilegie) sans viser une fonction reelle -- utile pour 
              valider l'offset sans dependre d'une adresse systeme correcte


08_retlibc_renamed.bin
-------------------------
Source      : copie de 06, rejouee contre le binaire retlib renomme
              (ex. retlib_renamed)
Cible       : copie renommee de retlib
Propriete violee : integrite de l'adresse de retour
Effet       : echoue. La longueur de argv[0] deplace la position de la
              variable d'environnement contenant "/bin/sh" sur la pile ;
              l'adresse codee en dur dans le payload ne correspond plus.
              Illustre la dependance des adresses return-to-libc au nom du
              binaire attaque


================================================================
Les descriptions des proprietes violees sont detaillees dans le rapport
(section E8, "Proprietes verifiables").