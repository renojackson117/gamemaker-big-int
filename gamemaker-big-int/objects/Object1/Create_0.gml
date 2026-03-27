/// @description 여기에 설명 삽입
// 이 에디터에 코드를 작성할 수 있습니다

show_message($"{big_int("1000000000000").mult("240").get()}")
show_message($"{big_int("1000000000000000000000").mult("240000000000000000").get()}")
show_message($"{big_int("1000000000000000000000").sum("240000000000000000").get()}")
show_message($"{big_int("1000000000000000000000").sub("240000000000000000").get()}")
show_message($"{big_int("1000000000000000000000").divide("240000000000000000").get()}")
show_message($"{big_int("1000000000000000000000").modular("240000000000000000").get()}")
/*
function ran(num,num2){
	var _arr = [
			[num.sum,function(a,b){return a+b;}],
			[num.sub,function(a,b){return a-b;}],
			[num.mult,function(a,b){return a*b;}],
			[num.divide,function(a,b){return a div b;}],
			[num.modular,function(a,b){return a mod b;}]
		]
	var _idx = irandom(4);
	var _func = _arr[_idx];
	var _n = irandom_range(-100,100);
	if(_idx == 3 || _idx == 4){
		if(_n == 0){ _n = irandom_range(1,100)*choose(-1,1) }
	}
	
	var _a;
	with(num){
		_a = _func[0](_n);
	}
	return [_a,_func[1](num2,_n)];
}

a = big_int(10);
b = 10;

for(var i = 0; i < 50; i++){
	var _k = ran(a,b);
	a = _k[0];
	b = _k[1];
	show_debug_message($"{a.get()} {b}")
}