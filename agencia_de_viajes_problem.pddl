(define (problem agencia_viaje)
	(:domain agencia_viaje)
	(:objects 
		c1 c2 c3 - ciudad
	    v1 v2 v3 - vuelo
		h1 h2 h3 - hotel
	)
	(:init 
		(Posicio a p1)	
		(Posicio b p2)	
		(Posicio c p3)	
	)

	(:goal (and
		(Posicio b p1)	
		(Posicio c p2)	
		(Posicio a p3)	
	))
)