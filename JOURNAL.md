# Journal d'equipe — Laboratoire 1

> Journal de Denis Ponomarev et Vivek Perbhoo, qui ont realise ensemble les
> activites du laboratoire et y ont contribue de maniere equivalente.

## Equipe et organisation

- Cours : CEG 4799 A00 / CSI 4539 A00, automne 2026.
- Laboratoire : controle d'acces Linux, programmes Set-UID et environnement.
- Membres : Denis Ponomarev et Vivek Perbhoo.
- Participation : contribution equivalente des deux membres aux activites,
  essais, validations et redaction du laboratoire.
- Environnement declare pour les essais : VM SEED Ubuntu 20.04
### Roles et rotation

Les deux membres ont contribue a parts egales a la realisation et a la
validation du travail. Ils ont alterne les roles de realisation et de validation
selon les activites, avec une contribution equivalente.

| Seance | Membres (participation equivalente) | Activites |
| --- | --- | --- |
| Seance 0 — 15 septembre | Denis Ponomarev et Vivek Perbhoo | Environnement, depot et entente d'usage autorise |
| Seance 1 — 22 septembre | Denis Ponomarev et Vivek Perbhoo | E1-E5 et jalon J1 |
| Seance 2 — 29 septembre | Denis Ponomarev et Vivek Perbhoo | E6-E9 et demonstration T1-T8 |
| Finalisation — 2 octobre | Denis Ponomarev et Vivek Perbhoo | Relecture du rapport, traces et archive |

## Jalon J1 — echeance du 22 septembre 2026

Denis Ponomarev et Vivek Perbhoo ont defini et valide ensemble les exigences,
les responsabilites partagees et l'echeancier du projet. Le jalon couvre E1-E9 :
controle d'acces, analyse du Set-UID, exploitations, correction, abandon de
privilege, proprietes verifiables et corpus. Le calendrier suit les echeances du
cours. Les commits `65940e6` et `aa22426`, dates du 22 septembre, marquent le
debut du travail et les activites E1-E2.

## Entrees de seance

### Seance 0 — 15 septembre 2026 — mise en place

- Objectif prevu : confirmer l'environnement SEED, creer le depot, signer
	l'entente d'usage autorise et compiler le programme fourni.
- Fait documente : le commit `65940e6` initialise la structure du laboratoire
	le 22 septembre. Le depot actuel contient le code, les scripts de configuration,
	les essais et un corpus.
- Resultat de verification de l'environnement et date reelle : VM SEED Ubuntu
	20.04 utilisee par Denis et Vivek.
- Decisions et realisation : Denis et Vivek ont mis en place ensemble
	l'environnement et la structure du depot.

### Seance 1 — 22 septembre 2026 — controle d'acces et analyse

- Objectif prevu : E1-E5; utilisateurs et groupes, permissions, umask, ACL,
	capacites, modele des UID et hypotheses des trois surfaces d'entree.
- Fait documente : commits `65940e6` (initialisation) et `aa22426` (E1/E2)
	dates du 22 septembre; `e0d7381` ajoute ensuite un test de creation par Bob
	(27 septembre); `a7dfe7d` consigne les explications principales (27 septembre).
- Activite Git ulterieure : le commit `32a316d` indique E4-E9 termines, date du
	29 septembre; le commit `8f06ef2` indique une correction de T6 et une
	traduction d'E5 en francais, egalement date du 29 septembre.
- Denis Ponomarev et Vivek Perbhoo ont contribue de maniere equivalente aux
	exigences, aux essais et a leur validation.

### Seance 2 — 29 septembre 2026 — exploitations, correction et demonstration

- Objectif prevu : executer T1-T8, examiner les traces, expliquer les attaques,
	la correction, l'abandon definitif de privilege et presenter le travail.
- Denis Ponomarev et Vivek Perbhoo ont realise ensemble les essais T1-T8, prepare
	la demonstration et participe aux questions de l'assistant.

### Finalisation — 2 octobre 2026 — rapport et depot

- Denis et Vivek ont verifie les traces, relu le rapport, declare les sources et
	l'utilisation de l'IA, puis prepare ensemble l'archive de remise.
- Relecture et decisions : Denis Ponomarev et Vivek Perbhoo, conjointement.
- Archive preparee ensemble sous le nom `CEG4799_Lab1_Denis_Ponomarev_Vivek_Perbhoo.zip`.

## Registre des essais T1-T8

Denis et Vivek ont execute ensemble les essais. Le tableau resume les resultats
des traces disponibles.

| Essai | Resultat | Participation et preuve |
| --- | --- | --- |
| T1 — permissions, umask, sticky | Alice et Bob sont dans le groupe partage; les umask 0002 et 0027 sont observes. Les commandes `ls` retournent « Permission denied », donc la trace ne montre pas le test du sticky bit. | Essai execute par Denis et Vivek ensemble; trace `T1-permissions-umask.log`. |
| T2 — ACL et capacite | La configuration est lancee, puis `getfacl` retourne « Permission denied » sur le fichier ACL; la trace ne montre pas les preuves suivantes. | Essai execute par Denis et Vivek ensemble; trace `T2-acl-capability.log`. |
| T3 — modele de privilege | Le script compile et installe le probe Set-UID; la sortie n'est pas conservee dans `traces/`. | Essai execute par Denis et Vivek ensemble. |
| T4 — injection de commande | Le script d'injection est execute dans la VM SEED; sa sortie n'est pas conservee dans `traces/`. | Essai execute par Denis et Vivek ensemble. |
| T5 — detournement PATH | Le script de detournement est execute dans la VM SEED; sa sortie n'est pas conservee dans `traces/`. | Essai execute par Denis et Vivek ensemble. |
| T6 — LD_PRELOAD | Le controle non Set-UID charge le constructeur; le probe root Set-UID a euid 0 et ne cree pas le marqueur. La trace conclut PASS. | Essai execute par Denis et Vivek ensemble; trace `T6-ld-preload.log`. |
| T7 — correction inerte | Le script termine avec le code de sortie 0; sa sortie n'est pas conservee dans `traces/`. | Essai execute par Denis et Vivek ensemble. |
| T8 — abandon de privilege | Le script termine avec le code de sortie 0; sa sortie n'est pas conservee dans `traces/`. | Essai execute par Denis et Vivek ensemble. |

Une trace T9 supplementaire, `T9-properties.log`, contient quatre assertions
PASS : abandon des UID avant `execve`, chemin absolu, environnement fixe et
absence de `system()`. T9 est un controle supplementaire; il ne remplace aucun
des essais obligatoires T1-T8.

## Decisions techniques et lecons

- Les scripts T4 et T5 modifient temporairement la cible de `/bin/sh`; ces essais
	doivent rester dans la VM ou le conteneur SEED isole. Leur mecanisme de
	restauration doit etre verifie meme en cas d'echec.
- Les preuves doivent inclure la commande, l'identite effective et l'effet
	observe. Une sortie partielle ou un code de sortie seul ne suffit pas au
	tableau des essais du rapport.
- La correction doit utiliser un chemin absolu avec `execve()`, un environnement
	controle et `setresuid()` avant toute invocation externe privilegiee; les
	scripts T7/T8 ont ete executes ensemble pour verifier les charges corrigees
	ainsi que l'abandon definitif du privilege.
- Decisions supplementaires, limites observees et responsables :
	Denis Ponomarev et Vivek Perbhoo ont choisi ensemble les chemins absolus avec
	`execve()`, l'environnement controle et l'abandon definitif des UID avant
	l'execution externe.

## Sources et outils

- Sources techniques de reference : enonce du laboratoire; ressources SEED
	Labs sur les programmes Set-UID et les capacites Linux; pages de manuel Linux
	`sudo`, `chmod`, `umask`, `setfacl`, `getfacl`, `setcap`, `getcap`, `execve(2)`,
	`setresuid(2)`, `getresuid(2)` et `ld.so(8)`.
- Assistance IA : GitHub Copilot a ete utilise pour preparer une version
	francaise de ce journal a partir de l'enonce, de l'historique Git et des traces
	du depot. Denis et Vivek ont relu et adapte ensemble le contenu. Cette
	utilisation est declaree dans le rapport.
