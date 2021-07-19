%Решение задачи коммивояжера: задан перечень городов и заданы стоимости проезда между ними.
%Требуется найти такой маршрут обхода всех городов такой, 
%чтобы суммарная стоимость проезда была минимальной и в каждом городе, кроме начального, 
%коммивояжёр побывал только один раз.

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
member(city,cities)   %проверка на вхождение в списке
setFromList(cities,cities) %создание множества из списка
commi(cities,cost)
packCitiesInSet(cities)
waysOfVisiting(city,cities,cities,cost)
clauses
path("Калининград","Осло",12).
path("Калининград","Минск",120).
path("Калининград","Атырау",40).
path("Калининград","Самара",90).
path("Минск","Осло",110).
path("Минск","Самара",52).
path("Минск","Атырау",100).
path("Осло","Атырау",32).
path("Осло","Самара",105).
path("Атырау","Самара",112).
/*
path("Цюрих","Бирмингем",30).
path("Астана","Бирмингем",20).
path("Астана","Цюрих",42).
path("Цюрих","Денвер",12).
path("Денвер","Астана",35).
path("Денвер","Бирмингем",34).*/


 %так как граф не ориентированный,
 % от одного города до другого, то же самое, что и наоборот
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
