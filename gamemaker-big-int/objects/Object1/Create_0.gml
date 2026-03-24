/// @description 여기에 설명 삽입
// 이 에디터에 코드를 작성할 수 있습니다
var _time = get_timer();
num = big_int("-25");
num = num.modular2(big_int("3"));
show_message(num.get());
show_message((get_timer()-_time)/1000000);