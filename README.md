# Modélisation SystemVerilog de l'algorithme de chiffrement ChaCha20

Ce projet présente l'implémentation matérielle et la modélisation en **SystemVerilog** de l'algorithme de chiffrement symétrique par flux **ChaCha20** (conçu par Daniel J. Bernstein). Ce travail adopte une approche de conception hiérarchique et modulaire, allant du bloc de calcul élémentaire jusqu'à l'intégration finale pilotée par une machine d'états finis (FSM).

Projet réalisé dans le cadre du cursus à **Mines Saint-Étienne**.

---

## Présentation de l'Algorithme ChaCha20

ChaCha20 manipule un état interne de **512 bits** modélisé sous la forme d'une matrice $4 \times 4$ de mots de 32 bits. La structure initiale de la matrice comprend :
* **Constantes (128 bits)** : Valeurs ASCII figées.
* **Clé (256 bits)** : Clé de chiffrement secrète partagée.
* **Compteur (32 bits)** : Incrémenté à chaque nouveau bloc de 512 bits.
* **Nonce (96 bits)** : Identifiant unique pour garantir l'unicité du keystream.

Le processus applique **20 rondes** alternant des transformations en colonnes (*RondeV*) et en diagonales (*RondeD*). Le brassage s'appuie sur le motif **ARX** (Addition, Rotation, XOR). Le flux de clé résultant (*keystream*) est combiné par une opération logique XOR avec le texte clair par morceaux (chunks) de 128 bits pour produire le texte chiffré.

---

## Architecture Matérielle & Modules

Le projet est structuré selon une hiérarchie stricte séparant la partie contrôle de la partie opérative :

1. **Module ARX** : Unité combinatoire réalisant l'addition modulo $2^{32}$, un OU exclusif (XOR), et un décalage circulaire gauche (de 7, 8, 12 ou 16 bits).
2. **Quarter Round** : Cascade de 4 blocs ARX instanciés de manière structurelle pour traiter 4 mots de 32 bits.
3. **chacha20_block** : Unité regroupant 4 instances parallèles de *Quarter Round* pour exécuter simultanément une double-ronde (colonne + diagonale) par cycle d'horloge.
4. **chacha20_fsm_moore** : Machine d'états de Moore gérant le séquencement (États : `Idle` ➡️ `Init` ➡️ `Ronde` ➡️ `End_Calcul`
