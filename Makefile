Sara_Buceta_Pol_Casacuberta_Alejandro_Espinosa.zip: src.zip practica_de_planificacion.pdf
	zip -r Sara_Buceta_Pol_Casacuberta_Alejandro_Espinosa.zip $^

src.zip: Basico/ Extension_1/ Extension_2/ Extension_3/ Extension_4/ Extra_2/ README.md
	zip -r src.zip $^

clean: 
	rm Sara_Buceta_Pol_Casacuberta_Alejandro_Espinosa.zip src.zip


