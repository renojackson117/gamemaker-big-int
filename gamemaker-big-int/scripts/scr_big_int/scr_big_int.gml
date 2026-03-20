// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
#macro BIG_INT_SAFE_MODE true
#macro BIG_INT_DECIMAL_CHUNK_LENGTH 7
#macro BIG_INT_DECIMAL_CHUNK_DIVISOR 10000000
#macro BIG_INT_BASE_CHUNK_DIVISOR 16777216

function big_int(val,negative = false){
	return new __class_big_int__(val, negative);
}

function __class_big_int__(val,negative = false) constructor{
	self.negative = negative;
	self.num_data = [];
	
	static set = function(val, _negative = negative)
	{
		negative = _negative;
		num_data = [];
		var _dec_chunks = [];
		
		if(is_struct(val)){
			negative = val.negative;
			num_data = val.num_data; 
		} else if(is_array(val)){
			num_data = val;
		} else if(is_string(val)){
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
		
		while(true){
			var _reminder = 0;
			var _has_left = false;
			for(var i = array_length(_dec_chunks)-1; i >= 0; i--){
				var _num = _dec_chunks[i] + _reminder * BIG_INT_DECIMAL_CHUNK_DIVISOR;
				_dec_chunks[i] = _num div BIG_INT_BASE_CHUNK_DIVISOR;
				_reminder = _num mod BIG_INT_BASE_CHUNK_DIVISOR;
				if(_dec_chunks[i] != 0){ _has_left = true; }
			}
			
			array_push(num_data,_reminder);
			if(!_has_left){ break; }
		}
		
		while(num_data[array_length(num_data)-1] == 0){ array_pop(num_data); }
	}
	
	static get = function(){
		var _dec_chunks = [0];
		
		for(var i = array_length(num_data)-1; i >= 0; i--){
			var _carry = num_data[i];
			
			for(var ii = 0; ii < array_length(_dec_chunks); ii++){
				var _val = _dec_chunks[ii] * BIG_INT_BASE_CHUNK_DIVISOR + _carry;
				_dec_chunks[ii] = _val mod BIG_INT_DECIMAL_CHUNK_DIVISOR;
				_carry = _val div BIG_INT_DECIMAL_CHUNK_DIVISOR;
				if(_carry > 0){ array_push(_dec_chunks, 0); }
			}
		}
		
		while(_dec_chunks[array_length(_dec_chunks)-1] == 0){ array_pop(_dec_chunks); }
		
		var _result = negative ? "-" : "";
		
		for(var i = array_length(_dec_chunks)-1; i >= 0; i--){
			_result += string(_dec_chunks);
		}
		
		return _result;
	}
	
	static add = function(source){
		if(negative == source.negative){
			return __add__(num_data);
		} else {
			var _cmp = cmp(a);
			if(_cmp == 1){
				return __sub__(num_data,a);
			}
		}
	}
	
	static cmp = function(source){	
		return __cmp__(self,source);
	}
	
	static __cmp__ = function(dest,source){
		if(!dest.negative && source.negative){ return 1; }
		if(dest.negative && !source.negative){ return -1; }
		
		var _sign = (!dest.negative && !source.negative) ? 1 : -1;
		
		if(array_length(dest.num_data) > array_length(source.num_data)){ return _sign; }
		if(array_length(dest.num_data) < array_length(source.num_data)){ return -_sign; }
		
		for(var i = array_length(dest.num_data)-1; i >= 0; i--){
			if(dest.num_data[i] > source.num_data[i]){ return _sign; }
			if(dest.num_data[i] < source.num_data[i]){ return -_sign; }
		}
		
		return 0;
	}
	
	static __add__ = function(dest,source){
		var _result_chunks = [0];
		var _carry = 0;
		
		for(var i = 0; i < array_length(_result_chunks); i++){
			var _dest_val = i < array_length(dest.num_data) ? dest.num_data[i] : 0;
			var _source_val = i < array_length(source.num_data) ? source.num_data[i] : 0;
			
			if(_dest_val == 0 && _source_val == 0){ break; }
			
			var _val = (_dest_val + _source_val) + _carry;
			
			_result_chunks[i] = _val mod BIG_INT_BASE_CHUNK_DIVISOR;
			_carry = _val div BIG_INT_BASE_CHUNK_DIVISOR;
			
			if(_carry > 0){ array_push(_result_chunks, 0); }
		}
		
		while(_result_chunks[array_length(_result_chunks)-1] == 0){ array_pop(_result_chunks);  }
		
		return big_int(_result_chunks, dest.negative != source.negative);
	}
	
	set(val);
}