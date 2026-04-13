// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
#macro BIG_INT_SAFE_MODE true
#macro BIG_INT_DECIMAL_CHUNK_LENGTH 4
#macro BIG_INT_DECIMAL_CHUNK_DIVISOR 10000
#macro BIG_INT_BASE_CHUNK_DIVISOR 32786

function big_int(val,negative = undefined){
	return new __class_big_int__(val, negative);
}

function __class_big_int__(val,_negative = undefined) constructor{
	self.negative = _negative;
	self.num_data = [];
	
	static __set__ = function(val, _negative = undefined)
	{
		negative = _negative;
		num_data = [];
		var _dec_chunks = [];
		
		if(is_struct(val)){
			negative ??= val.negative;
			num_data = variable_clone(val.num_data);
		} else if(is_array(val)){
			num_data = val;
		} else if(is_string(val)){
			if(BIG_INT_SAFE_MODE){
				if(val == ""){ show_error($"big_int: number(*num string is empty*)",false); }
				if(string_count(".",val) > 0){ show_error($"big_int: number(*num string contains .(point)*)",false); }
			}
			
			if(string_char_at(val,1) == "-"){
				negative ??= true;
				val = string_delete(val,1,1);
			} else {
				negative ??= false;
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
				negative ??= true;
				val = -val;
			} else {
				negative ??= false;
			}
			
			if(val < BIG_INT_DECIMAL_CHUNK_DIVISOR){
				num_data = [val];
				return;
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
		
		while(array_length(num_data) > 0 && num_data[array_length(num_data)-1] == 0){ array_pop(num_data); }
		if(array_length(num_data) == 0){ num_data = [0]; }
		
		if(array_length(num_data) == 1 && num_data[0] == 0){ negative = false; }
		
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
		
		while(array_length(_dec_chunks) > 0 && _dec_chunks[array_length(_dec_chunks)-1] == 0){ array_pop(_dec_chunks); }
		if(array_length(_dec_chunks) == 0){ _dec_chunks = [0]; }
		
		var _result = negative ? "-" : "";
		
		for(var i = array_length(_dec_chunks)-1; i >= 0; i--){
			_result += string_replace_all(string_format(_dec_chunks[i],BIG_INT_DECIMAL_CHUNK_LENGTH,0)," ","0");
		}
		
		while(string_char_at(_result,1) == "0" && string_length(_result) >= 2){ _result = string_delete(_result,1,1); }
		
		return _result;
	}
	
	static absolute = function(dest = self){
		return big_int(dest,false);
	}
	
	static flip = function(dest = self){
		var _int = big_int(dest);
		_int.negative = !_int.negative;
		return _int;
	}
	
	static sum = function(source){
		if(!is_struct(source)){ source = big_int(source); }
		return __sum__(self,source);
	}
	
	static sub = function(source){
		if(!is_struct(source)){ source = big_int(source); }
		return __sub__(self,source);
	}
	
	static get_sign = function(){
		if(array_length(num_data) == 1 && num_data[0] == 0){ self.negative = false; }
		return self.negative;
	}
	
	static cmp = function(source){
		if(!is_struct(source)){ source = big_int(source); }
		return __cmp__(self,source);
	}
	
	static divide = function(source){
		if(!is_struct(source)){ source = big_int(source); }
		return __div__(self,source);
	}
	
	static modular = function(source){
		if(!is_struct(source)){ source = big_int(source); }
		return __mod__(self,source);
	}
	
	static modular2 = function(source){
		if(!is_struct(source)){ source = big_int(source); }
		return __mod2__(self,source);
	}
	
	static mult = function(source){
		if(!is_struct(source)){ source = big_int(source); }
		return __mult__(self,source);
	}
	
	static __div__ = function(dest, source){
		if(array_length(source.num_data) == 1 && source.num_data[0] == 0){
			show_error($"big int: __div__ - divided with zero!",false);
		}
		
		var _negative = dest.negative != source.negative;
		dest = dest.absolute();
		source = source.absolute();
		
		var _result_chunks = [0];
		var current_rem = big_int(0);

		for (var i = array_length(dest.num_data) - 1; i >= 0; i--) {
		    // 1. 기존 나머지에 진수를 곱함 (자릿수 올리기)
		    current_rem = __mult_real__(current_rem,BIG_INT_BASE_CHUNK_DIVISOR);
		    // 2. 현재 마디를 더함
			var _curr_num = big_int(dest.num_data[i]);
		    current_rem = __sum__(current_rem,_curr_num);
			
		    // 3. 이진 탐색으로 q 찾기 (q * source <= current_rem 인 최대 q)
		    var q = find_q(current_rem, source);
			
		    // 4. 나머지 갱신
		    var subtract_val = __mult_real__(source,q);
		    current_rem = current_rem.sub(subtract_val);
    
		    // 5. 몫 저장
		    _result_chunks[i] = q;
		}
		
		while(array_length(_result_chunks) > 0 && _result_chunks[array_length(_result_chunks)-1] == 0){ 
		    array_pop(_result_chunks); 
		}
		
		if(array_length(_result_chunks) == 0){ _result_chunks = [0]; }
		
		return big_int(_result_chunks, _negative);
	}
	
	static find_q = function(_current_rem, _source_abs) {
	    if (__cmp__(_current_rem, _source_abs) == -1) return 0;

	    var _low = 0;
	    var _high = BIG_INT_BASE_CHUNK_DIVISOR - 1;
	    var _q = 0;

	    while (_low <= _high) {
	        var _mid = (_low + _high) div 2;
	        var _test_val = __mult_real__(_source_abs, _mid);
	        var _cmp_result = __cmp__(_current_rem, _test_val);

	        if (_cmp_result >= 0) {
	            _q = _mid;
	            _low = _mid + 1;
	        } else {
	            _high = _mid - 1;
	        }
	    }
		
	    return _q;
	}
	
	static __mult_real__ = function(dest, val) {
	    if (val == 0) return big_int(0);
	    if (val == 1) return dest;

	    var _result_data = [];
	    var _carry = 0;
	    for (var i = 0; i < array_length(dest.num_data); i++) {
	        var _val = dest.num_data[i] * val + _carry;
	        array_push(_result_data, _val mod BIG_INT_BASE_CHUNK_DIVISOR);
	        _carry = _val div BIG_INT_BASE_CHUNK_DIVISOR;
	    }
	    if (_carry > 0) array_push(_result_data, _carry);
	    return big_int(_result_data);
	}
	
	static __mult__ = function(dest, source){
		var _len_dest = array_length(dest.num_data);
	    var _len_source = array_length(source.num_data);
	    var _max_len = _len_dest + _len_source;
		var _result_chunks = array_create(_max_len,0);
		
		for(var i = 0; i < _len_dest; i++){
			var _dest_val = i < array_length(dest.num_data) ? dest.num_data[i] : 0;
			
			if(_dest_val == 0){ continue; }
			
			var _carry = 0;
			
			for(var ii = 0; ii < _len_source; ii++){
				
				var _source_val = ii < array_length(source.num_data) ? source.num_data[ii] : 0;
				
				if(_source_val == 0){ continue; }
			
				var _val = _result_chunks[i + ii] + (_dest_val * _source_val) + _carry;
			
				_result_chunks[i + ii] = _val mod BIG_INT_BASE_CHUNK_DIVISOR;
				_carry = _val div BIG_INT_BASE_CHUNK_DIVISOR;
			}
			
			if (_carry > 0) {
	            _result_chunks[i + _len_source] += _carry;
	        }
		}
		
		while(array_length(_result_chunks) > 0 && _result_chunks[array_length(_result_chunks)-1] == 0){ array_pop(_result_chunks);  }
		
		if(array_length(_result_chunks) == 0){ _result_chunks = [0]; }
		
		return big_int(_result_chunks, dest.negative != source.negative);
	}
	
	static __mod__ = function(dest, source){
		if(array_length(source.num_data) == 1 && source.num_data[0] == 0){
			show_error($"big int: __mod__ - divided with zero!",false);
		}
		var _negative = dest.negative;
		var _dest = absolute(dest);
		var _source = absolute(source);
		var _int = __sub__(_dest, __mult__(__div__(_dest, _source),_source));
		
		_int.negative = _negative;
		
		return _int;
	}
	
	static __mod2__ = function(dest, source){
		if(array_length(source.num_data) == 1 && source.num_data[0] == 0){
			show_error($"big int: __mod2__ - divided with zero!",false);
		}
		
		return __mod__(__sum__(__mod__(dest, source), source), source);
	}
	
	static __cmp__ = function(dest,source){
		var _dest_negative = dest.negative;
		var _source_negative = source.negative;
		
		if(array_length(dest.num_data) == 1 && dest.num_data[0] == 0){ _dest_negative = false; }
		if(array_length(source.num_data) == 1 && source.num_data[0] == 0){ _source_negative = false; }
		
		if(!_dest_negative && _source_negative){ return 1; }
		if(_dest_negative && !_source_negative){ return -1; }
		
		var _sign = (!dest.negative && !source.negative) ? 1 : -1;
		
		if(array_length(dest.num_data) > array_length(source.num_data)){ return _sign; }
		if(array_length(dest.num_data) < array_length(source.num_data)){ return -_sign; }
		
		for(var i = array_length(dest.num_data)-1; i >= 0; i--){
			if(dest.num_data[i] > source.num_data[i]){ return _sign; }
			if(dest.num_data[i] < source.num_data[i]){ return -_sign; }
		}
		
		return 0;
	}
	
	static __sum__ = function(dest, source){
		if(dest.negative != source.negative){
			if(source.negative){
				return __sub__(dest, source.flip());
			} else {
				return __sub__(source, dest.flip());
			}
		}
		
		var _result_chunks = [0];
		var _carry = 0;
		
		var _len_dest = array_length(dest.num_data);
	    var _len_source = array_length(source.num_data);
	    var _max_len = max(_len_dest, _len_source);
		
		for(var i = 0; i < _max_len || _carry > 0; i++){
			var _dest_val = i < array_length(dest.num_data) ? dest.num_data[i] : 0;
			var _source_val = i < array_length(source.num_data) ? source.num_data[i] : 0;
			
			var _val = (_dest_val + _source_val) + _carry;
			
			_result_chunks[i] = _val mod BIG_INT_BASE_CHUNK_DIVISOR;
			_carry = _val div BIG_INT_BASE_CHUNK_DIVISOR;
		}
		
		while(array_length(_result_chunks) > 0 && _result_chunks[array_length(_result_chunks)-1] == 0){ array_pop(_result_chunks);  }
		
		if(array_length(_result_chunks) == 0){ _result_chunks = [0]; }
		
		return big_int(_result_chunks, dest.negative);
	}
	
	static __sub__ = function(dest,source){
		if(dest.negative != source.negative){
			return __sum__(dest, source.flip());
		}
		
		var _negative = dest.negative;
		var _dest = absolute(dest);
		var _source = absolute(source);
		var _cmp = __cmp__(_dest,_source);
		
		if(_cmp == 0){ return big_int(0, false); }
		
		if(_cmp == -1){
			_negative = !_negative;
			var _temp = _dest;
			
			_dest = _source;
			_source = _temp;
		}
		
		var _result_chunks = [0];
		var _borrow = 0;
		
		var _len_dest = array_length(_dest.num_data);
	    var _len_source = array_length(_source.num_data);
	    var _max_len = max(_len_dest, _len_source);
		
		for(var i = 0; i < _max_len || _borrow > 0; i++){
			var _dest_val = i < array_length(_dest.num_data) ? _dest.num_data[i] : 0;
			var _source_val = i < array_length(_source.num_data) ? _source.num_data[i] : 0;
			
			var _val = (_dest_val - _source_val) - _borrow;

			_borrow = _val div BIG_INT_BASE_CHUNK_DIVISOR;
			if(_val < 0){ _val += BIG_INT_BASE_CHUNK_DIVISOR; _borrow = 1; }
			
			_result_chunks[i] = ((_val mod BIG_INT_BASE_CHUNK_DIVISOR) + BIG_INT_BASE_CHUNK_DIVISOR) mod BIG_INT_BASE_CHUNK_DIVISOR;
		}
		
		while(array_length(_result_chunks) > 0 && _result_chunks[array_length(_result_chunks)-1] == 0){ array_pop(_result_chunks);  }
		
		if(array_length(_result_chunks) == 0){ _result_chunks = [0]; }
		
		return big_int(_result_chunks, _negative);
	}
	
	__set__(val, _negative);
}