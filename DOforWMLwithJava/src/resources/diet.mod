/*********************************************
 * OPL 12.10.0.0 Model
 * Author: ALAINFLORENTChabrier
 * Creation Date: Mar 18, 2020 at 1:58:00 PM
 *********************************************/
  tuple Food
{
    key string name;
    float unit_cost;
    float qmin;
    float qmax;
};

{Food} diet_food=...;

tuple Nutrient
{
    key string name;
    float qmin;
    float qmax;
}

{Nutrient} diet_nutrients=...;

tuple food_nutrients
{
    key string name;
    float q1;
    float q2;
    float q3;
    float q4;
    float q5;
    float q6;
    float q7;
}

{food_nutrients} diet_food_nutrients=...;

float array_food_nutrients[f in diet_food][n in diet_nutrients];

// turn tuple set into an array
execute
{
for(var fn in diet_food_nutrients)
    for(var n in diet_nutrients)
        array_food_nutrients[diet_food.find(fn.name)][n]=fn[fn.getFieldName(1+Opl.ord(diet_nutrients,n))];
}

// Decision variables
dvar float qty[f in diet_food] in f.qmin .. f.qmax;

// cost
dexpr float cost=sum (f in diet_food) qty[f]*f.unit_cost;

// KPI
dexpr float amount[n in diet_nutrients] = sum(f in diet_food)
qty[f] * array_food_nutrients[f,n];

minimize cost;
subject to
{
forall(n in diet_nutrients) n.qmin<=amount[n]<=n.qmax;
}

dexpr float AMOUNT = sum(n in diet_nutrients) amount[n];
dexpr float COST = cost;

tuple Solution {
  key Food f;
  float quantity;
}

{Solution} SOLUTION = {<f, qty[f]> | f in diet_food};
 

execute
{
	writeln(AMOUNT);
	writeln(COST);
	writeln(SOLUTION);
}