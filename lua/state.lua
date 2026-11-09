local SSlua = dm.global_vars.SSlua

for _, state in SSlua.states do
	if state.internal_id == _state_id then
		return { state = state }
	end
end

return { state = nil }
