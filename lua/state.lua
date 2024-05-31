local SSlua = dm.global_vars:get_var("SSlua")

for _, state in SSlua:get_var("states") do
	if state:get_var("internal_id") == dm.state_id then
		return { state = state }
	end
end

return { state = nil }
