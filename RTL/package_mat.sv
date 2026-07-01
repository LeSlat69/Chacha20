// Package pour le type matrice 4x4 de mots de 32 bits
package package_matrice;

	// un mot de 32 bits
	typedef logic [31:0] mot;

	// la matrice d'etat ChaCha20 : 16 mots = 4 lignes x 4 colonnes
	typedef mot mat [0:3][0:3];

endpackage
