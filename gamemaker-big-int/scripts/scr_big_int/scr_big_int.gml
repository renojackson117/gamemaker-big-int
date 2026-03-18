// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
#macro BIG_INT_SAFE_MODE true
#macro BIG_INT_DECIMAL_CHUNK_LENGTH 7
#macro BIG_INT_DECIMAL_CHUNK_DIVISOR 10000000

function big_int(val) constructor{
	negative = false;
	num_data = [0];
	
	static number = function(val)
	{
		var _dec_chunks = [];
		
		if(is_string(val)){
			if(BIG_INT_SAFE_MODE){
				if(val == ""){ show_error($"big_int: number(*num string is empty*)",false); }
				if(string_count(".",val) > 0){ show_error($"big_int: number(*num string contains .(point)*)",false); }
			}
			
			if(string_char_at(val,1) == "-"){
				negative = true;
				val = string_delete(val,1,1);
			}
			
			for(var i = 1; i <= string_length(val); i += BIG_INT_DECIMAL_CHUNK_LENGTH){
				array_push(_dec_chunks,real(string_copy(val,i,BIG_INT_DECIMAL_CHUNK_LENGTH)));
			}
		} else if(is_real(val)){
			var _q = val;
			var _r = 0;
			
			do{
				_r = _q % BIG_INT_DECIMAL_CHUNK_DIVISOR
				_q = _q div BIG_INT_DECIMAL_CHUNK_DIVISOR
				array_push(_dec_chunks,real(string_copy(val,i,BIG_INT_DECIMAL_CHUNK_LENGTH)));
			} until(_reminder == 0)
		} else if(BIG_INT_SAFE_MODE){
			show_error($"big_int: number(*not a string or real*)",false)
		}
	}
	
	add(val);
}