#!/usr/bin/env bash
# Lab 3 - demo T1 a T5. Run with: bash demo_lab3.sh
# No set -e: the C crash and the T3 proof failure are intentional.
set +e

printf '\n========== 0 - SETUP ==========\n'
cd /home/seed/Documents/Laboratoire/lab1_v2 || exit 1
export PATH="$HOME/.local/bin:$PATH"
which gnatprove
gnatprove --version | head -n 2

printf '\n========== T1 -> E1, E2 : PROJET SPARK + FLOW ==========\n'
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator || exit 1
cat lab3_validator.gpr
cat src/validator.ads
gprbuild -P lab3_validator.gpr
echo "BUILD_EXIT=$?"
gnatprove -P lab3_validator.gpr --mode=flow
echo "FLOW_EXIT=$?"
cat obj/gnatprove/gnatprove.out

printf '\n========== T2 -> E3, E4 : CONTRATS + PREUVE RUNTIME ==========\n'
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator || exit 1
gnatprove -P lab3_validator.gpr --mode=prove --level=1 --report=all
echo "PROVE_EXIT=$?"
cat obj/gnatprove/gnatprove.out

printf '\n========== T3 -> E5 : ECHEC VOLONTAIRE + CONTRE-EXEMPLE ==========\n'
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/proof_failure_demo || exit 1
cp src/len_post2_pkg_FAIL.ads src/len_post2_pkg.ads || exit 1
sed -n '1,8p' src/len_post2_pkg.ads
cat src/len_post2_pkg.adb
gprclean -P proof_failure_demo.gpr
/home/seed/.local/bin/gnatprove -P proof_failure_demo.gpr \
  --mode=prove -u len_post2_pkg.adb --level=2 \
  --counterexamples=on --check-counterexamples=on --ce-steps=200 --report=all
echo "T3_FAIL_EXIT=$?"
printf '\nLire le contre-exemple : N=0, L=0 contredit L=N+1. Propriete fausse.\n'
printf 'Un exit code 0 ne signifie pas que toutes les obligations sont prouvees.\n'

printf '\n========== T3 : CORRECTION + REPREUVE ==========\n'
cp src/len_post2_pkg_FIXED.ads src/len_post2_pkg.ads || exit 1
sed -n '1,8p' src/len_post2_pkg.ads
gprclean -P proof_failure_demo.gpr
/home/seed/.local/bin/gnatprove -P proof_failure_demo.gpr \
  --mode=prove -u len_post2_pkg.adb --level=2 \
  --counterexamples=on --check-counterexamples=on --ce-steps=200 --report=all
echo "T3_FIXED_EXIT=$?"
# Reset for the next rehearsal; this does not change the main validator.
cp src/len_post2_pkg_FAIL.ads src/len_post2_pkg.ads || exit 1

printf '\n========== T4 -> E6 : CORPUS COMPLET C / SPARK ==========\n'
cd /home/seed/Documents/Laboratoire/lab1_v2 || exit 1
./lab3/tests/run_comparison.sh
echo "T4_CORPUS_EXIT=$?"
cat lab3/traces/T4-comparison.csv

printf '\n========== T4 : MEME ENTREE - PROGRAMME C ==========\n'
cp lab3/tests/cases/06-lab1-semicolon.txt lab3/build_c_ref/badfile || exit 1
cd lab3/build_c_ref || exit 1
./stack_ref
echo "C_EXIT=$?"

printf '\n========== T4 : MEME ENTREE - VALIDATEUR ADA/SPARK ==========\n'
cd /home/seed/Documents/Laboratoire/lab1_v2 || exit 1
./lab3/spark_validator/bin/main ./lab3/tests/cases/06-lab1-semicolon.txt
echo "SPARK_EXIT=$?"

printf '\n========== T5 -> E7 : PROPRIETE FONCTIONNELLE (OPTIONNEL) ==========\n'
cd /home/seed/Documents/Laboratoire/lab1_v2/lab3/spark_validator || exit 1
cat src/validator.ads
gnatprove -P lab3_validator.gpr --mode=prove --level=1 --report=all
echo "T5_EXIT=$?"
cat obj/gnatprove/gnatprove.out
