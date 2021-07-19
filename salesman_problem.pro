

domains 
city=string
cities=city*
cost=integer
facts
cheaper_way(cities,cost)
predicates
delete(city,cities,cities)
path(city,city,cost)
road(city,city,cost)
go(city,city,cities,cities,cost)
member(city,cities)   
setFromList(cities,cities) 
commi(cities,cost)
packCitiesInSet(cities)
waysOfVisiting(city,cities,cities,cost)
clauses
path("Denver","Oslo",12).
path("Denver","Moscow",120).
path("Denver","Atlanta",40).
path("Denver","Sidney",90).
path("Moscow","Oslo",110).
path("Moscow","Sidney",52).
path("Moscow","Atlanta",100).
path("Oslo","Atlanta",32).
path("Oslo","Sidney",105).
path("Atlanta","Sidney",112).


road(From,To,Cost):-path(From,To,Cost) ; path(To,From,Cost) .

member(Head,[Head|_]).
member(Head,[_|Tail]):-member(Head,Tail).

delete(_,[],[]).
delete(Elem,[Elem|Tail],ResTail):-delete(Elem,Tail,ResTail).
delete(Elem,[Head|Tail],[Head|ResTail]):-delete(Elem,Tail,ResTail).

setFromList([],[]).
setFromList([Head|Tail],List):- member(Head,Tail), !, setFromList(Tail,List).
setFromList([Head|Tail],[Head|List]):- setFromList(Tail,List).

packCitiesInSet(SetOfCities):-
	findall(City,path(City,_,_),CitiesList),
	setFromList(CitiesList,SetOfCities).

commi(VisitOrder,TotalCost):-
	packCitiesInSet(CitiesToVisit),
	path(StartCity,_,_),
	waysOfVisiting(StartCity,CitiesToVisit,VisitOrder,TotalCost),!.

waysOfVisiting(_,_,Way,TotalCost):-
	cheaper_way(Way,TotalCost).
waysOfVisiting(StartCity,CitiesToVisit,_,_):-
	go(StartCity,StartCity,CitiesToVisit,[StartCity],0),fail.

go(StartCity,From,CitiesToVisit,Way,TotalCost):-
	not(CitiesToVisit=[]),
	road(From,To,Cost),
	not(member(To,Way)),
	NewCost=Cost+TotalCost,
	delete(From,CitiesToVisit,NewCitiesToVisit), 
	go(StartCity,To,NewCitiesToVisit,[To|Way],NewCost).

go(StartCity,From,[],Way,TotalCost):-
	road(From,StartCity,Cost),
	NewCost=Cost+TotalCost,
	not(cheaper_way(_,_)),
	assert(cheaper_way([StartCity|Way],NewCost)).

go(StartCity,From,[],Way,TotalCost):-
	road(From,StartCity,Cost),
	NewCost=Cost+TotalCost,
	cheaper_way(_,FormerCost),
	NewCost<FormerCost,
	retract(cheaper_way(_,FormerCost)),
	assert(cheaper_way([StartCity|Way],NewCost)).

go(StartCity,From,[],Way,TotalCost):-
	road(From,StartCity,Cost),
	NewCost=Cost+TotalCost,
	cheaper_way(_,FormerCost),
	NewCost>=FormerCost.

goal
commi(Way,Cost).
