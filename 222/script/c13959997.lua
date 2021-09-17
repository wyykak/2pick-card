--2pick utilities

local cc=13959997
local this=_G["c"..cc]

function this.initial_effect(c)

end

function this.loadList(fname)
	local result={}
	local ct=1
	for l in io.lines(fname) do
		if l:sub(1,1)~="#" and tonumber(l) then
			result[ct]=tonumber(l)
			ct=ct+1
		end
	end
	return result
end

function this.writeList(t,fname)
	local f=io.open(fname,"w")
	f:write(table.concat(t,"\n"))
	f:flush()
	f:close()
end

function this.toSet(t)
	local result={}
	for _,v in pairs(t) do
		local cur=result
		for i=1,#tostring(v) do
			local c=tostring(v):sub(i,i)
			if not cur[tonumber(c)] then
				cur[tonumber(c)]={}
			end
			cur=cur[tonumber(c)]
			if i==#tostring(v) then
				cur[10]=true
			end
		end
	end
	return result
end

function this.toList(s)
	local result={}
	this.stol(s,result,"")
	return result
end

function this.stol(s,t,prefix)
	for i=0,9 do
		if s[i] then
			this.stol(s[i],t,prefix..i)
		end
	end
	if s[10] then
		t[#t+1]=tonumber(prefix)
	end
end

function this.stostr(s)
	local a="a"
	local result=""
	for i=0,9 do
		if s[i] then
			result=result..i
			result=result..this.stostr(s[i])
			result=result..")"
		end
	end
	if s[10] then
		result=result.."-"
	end
	return result
end
function this.dumpSet(s)
	local result=this.stostr(s)
	local cpr=""
	local ct=0
	local A="A"
	for i=1,#result do
		if result:sub(i,i)~=")" then
			if ct~=0 then
				cpr=cpr..string.char(A:byte()+ct-1)
				ct=0
			end
			if result:sub(i,i)~="-" then
				cpr=cpr..result:sub(i,i)
			end
		else
			ct=ct+1
		end
	end
	if ct~=0 then
		cpr=cpr..string.char(A:byte()+ct-1)
	end
	return cpr
end
function this.loadSet(str)
	local result={}
	local stack={result}
	local sp=1
	for i=1,#str do
		local c=str:sub(i,i)
		local A=("A"):byte()
		if c:byte()>=A then
			stack[sp][10]=true
			sp=sp-(c:byte()-A+1)
		else
			stack[sp][tonumber(c)]={}
			stack[sp+1]=stack[sp][tonumber(c)]
			sp=sp+1
		end
	end
	return result
end
function this.contains(s,op)
	local sop=tostring(op)
	local cur=s
	local found=false
	for i=1,#sop do
		if cur[tonumber(sop:sub(i,i))] then
			cur=cur[tonumber(sop:sub(i,i))]
		else
			break
		end
		if i==#sop and cur[10] then
			found=true
		end
	end
	return found
end
function this.add(s,op)
	local sop=tostring(op)
	local cur=s
	for i=1,#sop do
		if not cur[tonumber(sop:sub(i,i))] then
			cur[tonumber(sop:sub(i,i))]={}
		end
		cur=cur[tonumber(sop:sub(i,i))]
		if i==#sop then
			cur[10]=true
		end
	end
end
function this.del(s,op)
	if not this.contains(s,op) then return end
	local stack={s}
	local sp=1
	local sop=tostring(op)
	for i=1,#sop do
		stack[sp+1]=stack[sp][tonumber(sop:sub(i,i))]
		sp=sp+1
	end
	stack[sp][10]=nil
	while sp>1 do
		local isEmpty=true
		for i=0,10 do
			if stack[sp][i] then
				isEmpty=false
				break
			end
		end
		if isEmpty then
			stack[sp-1][tonumber(sop:sub(sp-1,sp-1))]=nil
			sp=sp-1
		else
			break
		end
	end
end
function this.initSet(s)
	s.contains=this.contains
	s.add=this.add
	s.del=this.del
end
function this.loadCardList(useBanList,ignoreBlackList,clCode)
	if not _G["c"..clCode] then
		_G["c"..clCode]={}
		Duel.LoadScript("c"..clCode..".lua")
	end
	local cl=_G["c"..clCode]
	local mainList=this.toList(this.loadSet(cl.Main))
	local extraList=this.toList(this.loadSet(cl.Extra))
	local ml={}
	local el={}
	local mat={}
	local eat={}
	for _,v in pairs(mainList) do
		local ca=Duel.ReadCard(v,CARDDATA_ALIAS)
		if not ca then
			Debug.Message("警告！卡片"..v.."不存在，卡表可能需要更新！")
			ca=0
		end
		local dif=ca-v
		local real=0
		if dif>-10 and dif<10 then
			real=ca
		else
			real=v
		end
		if not mat[real] then
			mat[real]={}
		end
		mat[real][#mat[real]+1]=v
	end
	for _,v in pairs(extraList) do
		local ca=Duel.ReadCard(v,CARDDATA_ALIAS)
		if not ca then
			Debug.Message("警告！卡片"..v.."不存在，卡表可能需要更新！")
			ca=0
		end
		local dif=ca-v
		local real=0
		if dif>-10 and dif<10 then
			real=ca
		else
			real=v
		end
		if not eat[real] then
			eat[real]={}
		end
		eat[real][#eat[real]+1]=v
	end
	local bl=this.loadSet(cl.BanList)
	local bll=this.loadSet(cl.BlackList)
	this.initSet(bl)
	this.initSet(bll)
	for k,_ in pairs(mat) do
		if (ignoreBlackList or not bll:contains(k)) and (not useBanList or not bl:contains(k)) then
			ml[#ml+1]=k
		end
	end
	for k,_ in pairs(eat) do
		if (ignoreBlackList or not bll:contains(k)) and (not useBanList or not bl:contains(k)) then
			el[#el+1]=k
		end
	end
	return ml,el,mat,eat
end

function this.createSkill(c,cc,n,desc,needtg)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_IGNITION)
	if not needtg then
		e:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CANNOT_INACTIVATE|EFFECT_FLAG_CANNOT_NEGATE|EFFECT_FLAG_UNCOPYABLE)
	else
		e:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CANNOT_INACTIVATE|EFFECT_FLAG_CANNOT_NEGATE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CARD_TARGET)
	end
	e:SetRange(LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE|LOCATION_SZONE|LOCATION_GRAVE|LOCATION_REMOVED)
	e:SetCountLimit(n,EFFECT_COUNT_CODE_DUEL|cc)
	e:SetDescription(desc)
	return e
end
	