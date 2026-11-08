# Demonstration Lab 3 (copier-coller) — CEG4799/CSI4539

Ce guide est base sur des executions reelles effectuees dans ce workspace.

Important:
- Les echecs de T3 (preuve) et T4 (C vulnerable) sont attendus et font partie de la demonstration.
- Les commandes ci-dessous ont ete testees.
- Ne pas masquer les erreurs: on evite les pipelines qui cachent le code de retour.

## 0) Demarrage terminal (neuf)

Objectif:
- Partir d un terminal propre, definir le PATH, verifier que `gnatprove` est bien resolu.

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2
export PATH="$HOME/.local/bin:$PATH"
echo "PWD=$PWD"
which gnatprove
gnatprove --version | head -n 2
```

Ce qu il faut montrer:
- `which gnatprove` pointe vers `/home/seed/.local/bin/gnatprove`.
- `gnatprove` repond bien.

Ce que cela prouve / ne prouve pas:
- Prouve que l outillage est accessible dans le terminal de demo.
- Ne prouve pas encore la validite du projet.

Phrase courte a dire:
- "Je commence par verifier l environnement de preuve pour garantir une demonstration reproductible."

---

## T1 -> E1, E2

## T1.1 Afficher le projet GPR et le module SPARK

Objectif:
- Montrer la designation SPARK et les contrats de flux (`Global`, `Depends`).

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator
cat lab3_validator.gpr
sed -n '1,220p' src/validator.ads
```

Points a montrer dans la sortie:
- `project Lab3_Validator` et les repertoires `src`, `obj`, `bin`.
- `package Validator with SPARK_Mode => On is`.
- Les clauses `Global => null` et `Depends => ...`.

Ce que cela prouve / ne prouve pas:
- Prouve la structure E1 et l isolation (coeur SPARK dans `validator`, harnais I/O dans `main`).
- Ne prouve pas encore l absence d avertissements flow.

Phrase a dire:
- "Le coeur de validation est en SPARK, le harnais I/O est separe."

Fichiers:
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator/lab3_validator.gpr`
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator/src/validator.ads`

## T1.2 Build puis flow

Objectif:
- Montrer build OK + analyse de flux propre.

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator
mkdir -p obj bin
gprbuild -P lab3_validator.gpr
echo "BUILD_EXIT=$?"

gnatprove -P lab3_validator.gpr --mode=flow
echo "FLOW_EXIT=$?"

sed -n '1,220p' obj/gnatprove/gnatprove.out
```

Points a montrer:
- `BUILD_EXIT=0`.
- `FLOW_EXIT=0`.
- Dans `gnatprove.out`, pour `validator`: `0 errors, 0 warnings`.

Ce que cela prouve / ne prouve pas:
- Prouve E1/E2 pour l analyse de flux du module validateur.
- Ne prouve pas encore toutes les obligations runtime (c est T2).

Phrase a dire:
- "Le module SPARK passe l analyse de flux sans avertissement sur les unites du validateur."

---

## T2 -> E3, E4

## T2.1 Rappeler les contrats

Objectif:
- Montrer les hypotheses explicites (longueur, politique caracteres, postcondition).

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator
sed -n '1,220p' src/validator.ads
sed -n '20,120p' src/validator.adb
```

Points a montrer:
- `Max_Length : constant Positive := 100;`
- `Fits_Buffer`, `Is_Allowed_Char`, `Is_Allowed_Input`.
- `subtype Policy_Char is Character with Dynamic_Predicate => Is_Allowed_Char (Policy_Char);`
- Dans `Copy_Validated` (interne):
  - `Pre => Fits_Buffer (Input) and then Is_Allowed_Input (Input)`.
- Postcondition de `Validate_And_Copy`.

Phrase a dire:
- "Les hypotheses de validation sont exprimees explicitement: predicate de sous-type pour la whitelist et precondition interne avant copie."

## T2.2 Preuve GNATprove (prove)

Objectif:
- Montrer la preuve d execution sure et les statistiques.

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator
gnatprove -P lab3_validator.gpr --mode=prove --level=1 --report=all
echo "PROVE_EXIT=$?"

sed -n '1,260p' obj/gnatprove/gnatprove.out
```

Sortie attendue (lignes clefs deja observees):
- `PROVE_EXIT=0`
- `Run-time Checks ... Unproved .` (aucune obligation runtime non prouvee)
- `Functional Contracts 2 ... Unproved .`
- Unites analysees: `main` (hors SPARK) et `validator` (prouve).

Ce que cela prouve / ne prouve pas:
- Prouve absence d erreurs d execution sur le module SPARK analyse (`validator`).
- Ne prouve pas tout l OS, les bibliotheques externes, ni le harnais hors SPARK.

Phrase a dire:
- "La preuve couvre les checks runtime du validateur SPARK et decharge toutes les obligations de cette unite."

Fichiers:
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator/src/validator.ads`
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator/src/validator.adb`

---

## T3 -> E5

Objectif:
- Montrer un vrai echec de preuve, expliquer la cause, corriger exactement, puis reprouver.
- Procedure repetable et sure, sans toucher au projet final `spark_validator`.

### T3.0 Contre-exemple GNATprove "valide" (valeurs affichees)

But:
- Satisfaire explicitement l exigence "lire le contre-exemple produit par l outil" avec des valeurs affichees par GNATprove en mode verifie (`check-counterexamples=on`).

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo
cp src/len_post2_pkg_FAIL.ads src/len_post2_pkg.ads

/home/seed/.local/bin/gnatprove -P proof_failure_demo.gpr \
  --mode=prove -u len_post2_pkg.adb --level=2 \
  --counterexamples=on --check-counterexamples=on --ce-steps=200 --report=all
echo "T3_CEX_VALIDATED_EXIT=$?"
```

Sortie observee (GNATprove):
- `high: postcondition might fail`
- `e.g. when L = 0 and N = 0`

Lecture et classement E5:
- Le contre-exemple donne une affectation concrete (`N=0`, `L=0`).
- La propriete exigee est `L = N + 1`, donc `0 = 1` est faux.
- Classement: **propriete fausse** (specification a corriger).

Correction et repreuve:

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo
cp src/len_post2_pkg_FIXED.ads src/len_post2_pkg.ads

/home/seed/.local/bin/gnatprove -P proof_failure_demo.gpr \
  --mode=prove -u len_post2_pkg.adb --level=2 \
  --counterexamples=on --check-counterexamples=on --ce-steps=200 --report=all
echo "T3_CEX_VALIDATED_FIXED_EXIT=$?"

# reset demo state
cp src/len_post2_pkg_FAIL.ads src/len_post2_pkg.ads
```

Sortie attendue apres correction:
- `info: postcondition proved`

Ce que cela prouve / ne prouve pas:
- Prouve strictement la boucle E5: echec -> contre-exemple outille lu -> classement -> correction -> preuve retablie.
- Ne remplace pas l analyse metier du validateur principal.

### T3.1 Etat echec (intentionnel)

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo
cp src/validator_failure_FAIL.ads src/validator_failure.ads

/home/seed/.local/bin/gnatprove -P proof_failure_demo.gpr \
  --mode=prove --level=2 -u validator_failure.adb \
  --counterexamples=on --check-counterexamples=on --ce-steps=200 --report=provers
echo "T3_FAIL_EXIT=$?"  # peut etre 0 meme si une obligation reste non prouvee
```

Point a montrer:
- Ligne du type:
  - `postcondition might fail, cannot prove Copied_Length = Input'Length + 1`
- `T3_FAIL_EXIT=0` possible: ce code de retour ne signifie pas "tout prouve".

Interpretation:
- C est un **echec attendu**: propriete fausse (specification incorrecte).
- Le succes/echec de la preuve se lit dans les messages et le resume `Unproved`, pas uniquement via `$?`.

Note technique importante (cas `validator_failure`):
- Avec `--check-counterexamples=on`, GNATprove peut ne pas afficher de valeurs pour cet exemple.
- Avec `--check-counterexamples=off`, GNATprove affiche un modele brut (ex. `Copied_Length = 1`, `Input'Last = 0`).
- Selon la doc SPARK, ce mode brut peut inclure des contre-exemples non faisables; il sert au diagnostic, pas a lui seul a conclure la faisabilite d execution.

### T3.1bis Contre-exemple concret (valeurs)

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo
cp src/validator_failure_FAIL.ads src/validator_failure.ads
gprbuild -P proof_failure_demo.gpr src/cex_demo.adb
./obj/cex_demo
```

Sortie concrete observee:
- `INPUT="A"`
- `INPUT_LENGTH= 1`
- `ACCEPTED=TRUE`
- `COPIED_LENGTH= 1`
- `WRONG_SPEC_EXPECTED= 2`

Interpretation rapide:
- La specification FAIL exige `Copied_Length = Input'Length + 1`.
- Le comportement reel (et le contrat corrige) donne `Copied_Length = Input'Length`.
- Donc pour `Input="A"`: `1 /= 2`, contradiction explicite.

### T3.2 Montrer la correction exacte

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo
diff -u src/validator_failure_FAIL.ads src/validator_failure_FIXED.ads
```

Point a montrer:
- La seule difference:
  - `Copied_Length = Input'Length + 1`
  devient
  - `Copied_Length = Input'Length`

### T3.3 Repreuve apres correction

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo
cp src/validator_failure_FIXED.ads src/validator_failure.ads

gnatprove -P proof_failure_demo.gpr --mode=prove --level=1 --report=all
echo "T3_AFTER_FIX_EXIT=$?"
```

Points a montrer:
- Plus de message `postcondition might fail`.
- `T3_AFTER_FIX_EXIT=0`.

### T3.4 Remettre l etat de base (repetable)

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo
cp src/validator_failure_FAIL.ads src/validator_failure.ads
echo "T3_STATE_RESET=FAIL_VERSION_RESTORED"
```

Ce que cela prouve / ne prouve pas:
- Prouve la methode E5: echec -> diagnostic -> correction -> preuve retablie.
- Ne prouve pas que toute propriete fonctionnelle possible est couverte.

Phrase a dire:
- "Ici je montre un echec de preuve volontairement provoque, je l identifie comme propriete fausse, je corrige la specification, puis je reprouve."

Fichiers:
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo/src/validator_failure.ads`
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo/src/validator_failure_FAIL.ads`
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo/src/validator_failure_FIXED.ads`
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo/src/cex_demo.adb`

---

## T4 -> E6

Objectif:
- Comparer C et SPARK sur le meme corpus, puis montrer un cas dangereux en direct.

### T4.1 Executer corpus commun

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2
./lab3/tests/run_comparison.sh
echo "T4_CORPUS_EXIT=$?"

cat lab3/traces/T4-comparison.csv
```

Points a montrer dans le tableau:
- Pour les cas valides courts: SPARK `ACCEPTED=TRUE`.
- Pour les cas dangereux et/ou hors limite: SPARK `ACCEPTED=FALSE`.
- Plusieurs cas C ont `c_exit=139` (segmentation fault observee).

Interpretation des codes:
- `139` = process termine par signal `SIGSEGV`.
- `0` cote SPARK = execution normale du validateur (avec rejet explicite quand necessaire).

### T4.2 Cas dangereux individuel (meme entree)

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2

# C vulnerable
cp lab3/tests/cases/06-lab1-semicolon.txt lab3/build_c_ref/badfile
cd lab3/build_c_ref
./stack_ref
echo "C_DANGER_EXIT=$?"

# SPARK
cd /home/seed/Documents/Laboratoire/lab1_v2
./lab3/spark_validator/bin/main ./lab3/tests/cases/06-lab1-semicolon.txt
echo "SPARK_DANGER_EXIT=$?"
```

Sortie typique observee:
- C:
  - `Input size: 289`
  - `Segmentation fault`
  - `C_DANGER_EXIT=139`
- SPARK:
  - `FITS_BUFFER=FALSE`
  - `ALLOWED_CHARS=FALSE`
  - `ACCEPTED=FALSE`
  - `SPARK_DANGER_EXIT=0`

Ce que cela prouve / ne prouve pas:
- Prouve un comportement observe dangereux en C et un rejet sur de meme entree en SPARK.
- Ne prouve pas que C echoue toujours de la meme facon sur toutes plateformes (UB).

Phrase a dire:
- "Sur la meme charge, le C montre une defaillance observee (segfault), alors que SPARK rejette proprement sans corruption memoire visible."

Fichiers:
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/reference/c/stack_reference.c`
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator/src/validator.adb`
- `/home/seed/Documents/Laboratoire/lab1_v2/lab3/traces/T4-comparison.csv`

---

## T5 -> E7 (optionnel)

Statut ici: **complete (optionnel)**.

Objectif:
- Montrer qu une propriete fonctionnelle est prouvee (pas seulement runtime safety).

```bash
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator
sed -n '21,70p' src/validator.ads

gnatprove -P lab3_validator.gpr --mode=prove --level=1 --report=all > /tmp/lab3_t5_prove.out 2>&1
echo "T5_PROVE_EXIT=$?"
grep -n "Functional Contracts\|postcondition proved" /tmp/lab3_t5_prove.out
sed -n '1,80p' obj/gnatprove/gnatprove.out
```

Point a montrer:
- `Functional Contracts 2 ... Unproved .`
- Lignes `postcondition proved`.

Phrase a dire:
- "Au-dela des checks runtime, on prouve aussi une propriete fonctionnelle: si `Accepted=TRUE`, alors la longueur copiee egale la longueur d entree, et l entree respecte `Fits_Buffer` + la whitelist `Policy_Char`."

---

## Mapping rapide E <-> T

| T | E couverts | Preuve principale |
| --- | --- | --- |
| T1 | E1, E2 | build + flow + designation SPARK + Global/Depends |
| T2 | E3, E4 | contrats de validation + prove summary |
| T3 | E5 | echec volontaire, diagnostic, correction, repro preuve |
| T4 | E6 | corpus commun C/SPARK + cas dangereux individuel |
| T5 (opt.) | E7 | postcondition fonctionnelle prouvee |

---

## Mini checklist 15 minutes (live)

1. Verifier `PWD` et `which gnatprove`.
2. T1: montrer `validator.ads` + lancer build/flow + montrer `0 warnings`.
3. T2: lancer prove + montrer resume (runtime checks et scope).
4. T3: lancer echec volontaire, montrer diff de correction, relancer preuve OK.
5. T4: lancer script corpus, ouvrir CSV, refaire un cas dangereux en direct C puis SPARK.
6. T5 optionnel: montrer `Functional Contracts` prouves (si le temps le permet).
7. Conclure limites: preuve du module SPARK, pas preuve du systeme complet.

---

## Rappels importants pour la demo orale

- Echec T3 est **attendu** (preuve de diagnostic E5).
- Echec C en T4 est **observe** sur cette VM (segfault), mais on ne generalise pas l UB.
- L IA est interdite pendant la demo: ce guide sert d aide memoire hors demo.
