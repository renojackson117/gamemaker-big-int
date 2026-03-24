/// @description 여기에 설명 삽입
// 이 에디터에 코드를 작성할 수 있습니다
var _time = get_timer();
num = big_int("100").mult(big_int("2000"));show_message(num.get())
num = big_int("51");show_message(num)
num = num.divide(big_int("17"));
show_message(num.get());
show_message((get_timer()-_time)/1000000);