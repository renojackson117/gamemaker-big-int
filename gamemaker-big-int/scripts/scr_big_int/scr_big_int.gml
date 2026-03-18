// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
#macro BIG_INT_SAFE_MODE true
#macro BIG_INT_DECIMAL_CHUNK_LENGTH 7
#macro BIG_INT_DECIMAL_CHUNK_DIVISOR 10000000
#macro BIG_INT_BASE_CHUNK_DIVISOR 16777216

function big_int(val){
	return new __class_big_int__(val);
}

function __class_big_int__(val) constructor{
	negative = false;
	num_data = [];
	
	static set = function(val)
	{
		num_data = [];
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
			
			var i = string_length(val);
			while(true){
				var _idx = i-BIG_INT_DECIMAL_CHUNK_LENGTH+1;
				array_push(_dec_chunks,real(string_copy(val,max(_idx,1),min(BIG_INT_DECIMAL_CHUNK_LENGTH,BIG_INT_DECIMAL_CHUNK_LENGTH+_idx-1))));
				if(_idx <= 1){ break; }	
				i -= BIG_INT_DECIMAL_CHUNK_LENGTH;
			}
		} else if(is_real(val)){
			if(sign(val) == -1){
				negative = true;
				val = -val;
			}
			
			do{
				array_push(_dec_chunks,val % BIG_INT_DECIMAL_CHUNK_DIVISOR);
				val = floor(val/BIG_INT_DECIMAL_CHUNK_DIVISOR);
			} until(val <= 0)
		} else if(BIG_INT_SAFE_MODE){
			show_error($"big_int: number(*not a string or real*)",false)
		}
		show_message(_dec_chunks)
		while(true){
			var _reminder = 0;
			var _has_left = false;
			for(var i = array_length(_dec_chunks)-1; i >= 0; i--){
				var _num = _dec_chunks[i] + _reminder * BIG_INT_DECIMAL_CHUNK_DIVISOR;//show_message($"_num {_dec_chunks[i] + _reminder * BIG_INT_DECIMAL_CHUNK_DIVISOR}")
				_dec_chunks[i] = _num div BIG_INT_BASE_CHUNK_DIVISOR;
				_reminder = _num mod BIG_INT_BASE_CHUNK_DIVISOR;//show_message($"{_dec_chunks[i]} {_reminder}")
				if(_dec_chunks[i] != 0){ _has_left = true; }
			}
			
			array_push(num_data,_reminder);
			if(!_has_left){ break; }
		}
		show_message(num_data)
		if (array_length(num_data) == 0) array_push(num_data, 0);
	}
	
	static get = function(){
		var _dec_chunks = [0];
		
		for(var i = array_length(num_data)-1; i >= 0; i--){
			var _carry = num_data[i];
			
			for(var ii = 0; ii < array_length(_dec_chunks); ii++){
				var _val = _dec_chunks[ii] * BIG_INT_BASE_CHUNK_DIVISOR + _carry;
				_dec_chunks[ii] = _val mod BIG_INT_DECIMAL_CHUNK_DIVISOR;
				_carry = _val div BIG_INT_DECIMAL_CHUNK_DIVISOR;
				if(_carry > 0){ array_push(_dec_chunks, _carry mod BIG_INT_DECIMAL_CHUNK_DIVISOR); }
			}
		}
		
		return _dec_chunks;
	}
	
	set(val);
}