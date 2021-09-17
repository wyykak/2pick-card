--2Pick技能-同调强化
--By wyykak

if not c13959997 then
	c13959997={}
	Duel.LoadScript("c13959997.lua")
end
local tpu=c13959997

local cc=13959982
local this=_G["c"..cc]

function this.initial_effect(c)
	local e1=tpu.createSkill(c,cc,3,aux.Stringid(cc,0),true)
	e1:SetTarget(this.tg1)
	e1:SetOperation(this.op1)
	c:RegisterEffect(e1)
	
	local e2=tpu.createSkill(c,cc-10,1,aux.Stringid(cc,1),false)
	e2:SetCost(this.cost2)
	e2:SetTarget(this.tg2)
	e2:SetOperation(this.op2)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e3)
end

function this.filter1(c)
	return c:IsFaceup() and c:GetLevel()>0
end

function this.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingTarget(this.filter1,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SelectTarget(tp,this.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetChainLimit(aux.FALSE)
end

function this.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not this.filter1(tc) then
		return
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(Duel.AnnounceLevel(tp))
	e1:SetReset(RESETS_STANDARD)
	tc:RegisterEffect(e1)
	if not tc:IsType(TYPE_TUNER) and Duel.SelectYesNo(tp,aux.Stringid(cc,2)) then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_TUNER)
		e2:SetReset(RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end

function this.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_EXTRA,0,nil,POS_FACEDOWN)
	if chk==0 then
		return not g:IsExists(function(c) return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER) and not c:IsAbleToRemoveAsCost(POS_FACEDOWN) end,1,nil)
	end
	Duel.Remove(g:Filter(function(c) return not (c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER)) end,nil),POS_FACEDOWN,REASON_COST)
end

function this.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetChainLimit(aux.FALSE)
end

function this.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,cc)>0 then
		return
	end
	local esp=Effect.CreateEffect(e:GetHandler())
	esp:SetType(EFFECT_TYPE_FIELD)
	esp:SetCode(EFFECT_SPSUMMON_PROC)
	esp:SetDescription(aux.Stringid(cc,3))
	esp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	esp:SetRange(LOCATION_EXTRA)
	esp:SetValue(SUMMON_TYPE_SYNCHRO)
	esp:SetCondition(this.syncon)
	esp:SetOperation(this.synop)
	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	e1:SetTarget(function(_,c) return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER) and not c:IsFaceup() end)
	e1:SetLabelObject(esp)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,cc,0,0,1)
end

function this.matfilter(c,sc)
	return ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_HAND)) and c:GetLevel()>0 and c:IsCanBeSynchroMaterial(sc)
end

function this.syncon(e,c,smat,mg,min,max)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local minc=1
	local maxc=99
	if min then
		if min>minc then minc=min end
		if max<maxc then maxc=max end
	end
	local rmg=mg
	if not mg then
		rmg=Duel.GetMatchingGroup(this.matfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil,c)
	end
	if smat then 
		if this.matfilter(smat,c) and smat:GetLevel()<=c:GetLevel() then
			rmg:RemoveCard(smat)
			return rmg:CheckWithSumEqual(Card.GetLevel,c:GetLevel()-smat:GetLevel(),minc-1,maxc-1)
		else
			return false
		end
	else
		return rmg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),minc,maxc)
	end
end

function this.synop(e,tp,eg,ep,ev,re,r,rp,c,smat,mg,min,max)
	local tp=c:GetControler()
	local minc=1
	local maxc=99
	if min then
		if min>minc then minc=min end
		if max<maxc then maxc=max end
	end
	local rmg=mg
	if not mg then
		rmg=Duel.GetMatchingGroup(this.matfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil,c)
	end
	local mat
	if smat then 
		rmg:RemoveCard(smat)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		mat=rmg:SelectWithSumEqual(tp,Card.GetLevel,c:GetLevel()-smat:GetLevel(),minc-1,maxc-1)
		mat:AddCard(smat)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		mat=rmg:SelectWithSumEqual(tp,Card.GetLevel,c:GetLevel(),minc,maxc)
	end
	c:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_SYNCHRO)
end