(define (problem agencia_viaje)
	(:domain agencia_viaje)
	(:objects 
		a b c - valor
		p1 p2 p3 - posicio
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