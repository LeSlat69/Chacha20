// Package contenant l'enumeration des etats de la FSM
package package_state;

	// etats de la FSM Moore qui pilote ChaCha20
	typedef enum logic [2:0] {
		Idle,        // attente du start
		Init,        // chargement de l'etat initial
		Ronde,       // execution des 20 rondes
		End_Calcul,  // fin du keystream, end_o = 1
		Wait_Data,   // attente d'un bloc de texte clair valide
		Xor          // XOR entre data_i et keystream
	} state_t;

endpackage
