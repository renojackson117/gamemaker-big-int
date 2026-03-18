// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
#macro BIG_INT_SAFE_MODE true
#macro BIG_INT_DECIMAL_CHUNK_LENGTH 7
function big_int(val) constructor{
	num_data = [0];
	static number = function(val){
		var _dec_chunks = [];
		
		if(is_string(val)){
			if(BIG_INT_SAFE_MODE){
				if(string_count(".",val) > 0){
					show_error($"big_int: number(*num string contains .(point)*)",false)
				}
			}
			
			for(var i = 1; i <= string_length(val); i += BIG_INT_DECIMAL_CHUNK_LENGTH){
				array_push(_dec_chunks,real(string_copy(val,i,BIG_INT_DECIMAL_CHUNK_LENGTH)));
			}
		} else if(is_real(val)){
			var _quotient = val;
			var _reminder = 0;
			do{
				array_push(_dec_chunks,real(string_copy(val,i,BIG_INT_DECIMAL_CHUNK_LENGTH)));
			} until(_reminder == 0)
		} else if(BIG_INT_SAFE_MODE){
			show_error($"big_int: number(*not a string or real*)",false)
		}
	}
	add(val);
}