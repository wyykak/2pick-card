--2Pick技能-超量强化
--By wyykak

if not c13959997 then
	c13959997={}
	Duel.LoadScript("c13959997.lua")
end
local tpu=c13959997

local cc=13959983
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
	
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	g:ForEach(function(c)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESETS_STANDARD)
		c:RegisterEffect(e1)
	end)
end

function this.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_EXTRA,0,nil,POS_FACEDOWN)
	if chk==0 then
		return not g:IsExists(function(c) return c:IsType(TYPE_XYZ) and c:IsType(TYPE_MONSTER) and not c:IsAbleToRemoveAsCost(POS_FACEDOWN) end,1,nil)
	end
	Duel.Remove(g:Filter(function(c) return not (c:IsType(TYPE_XYZ) and c:IsType(TYPE_MONSTER)) end,nil),POS_FACEDOWN,REASON_COST)
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
	esp:SetDescription(aux.Stringid(cc,2))
	esp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	esp:SetRange(LOCATION_EXTRA)
	esp:SetValue(SUMMON_TYPE_SYNCHRO)
	esp:SetCondition(this.xyzcon)
	esp:SetOperation(this.xyzop)
	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	e1:SetTarget(function(_,c) return c:IsType(TYPE_XYZ) and c:IsType(TYPE_MONSTER) and not c:IsFaceup() end)
	e1:SetLabelObject(esp)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,cc,0,0,1)
end

function this.matfilter(c,sc)
	return c:IsFaceup() and (c:GetLevel()>0 or c:GetRank()>0) and c:IsCanBeXyzMaterial(sc)
end

function this.matfilter2(c,rk)
	return c:IsLevel(rk) or c:IsRank(rk)
end

function this.xyzcon(e,c,og,min,max)
	if c==nil then return true end
	if min and min>1 then return false end
	if max and max<1 then return false end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	if og and not min and #og>1 then return false end
	local tp=c:GetControler()
	local rmg
	if og then
		rmg=og
	else
		rmg=Duel.GetMatchingGroup(this.matfilter,tp,LOCATION_MZONE,0,nil,c)
	end
	return rmg:IsExists(this.matfilter2,1,nil,c:GetRank())
end

function this.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	local rmg
	if og then
		rmg=og
	else
		rmg=Duel.GetMatchingGroup(this.matfilter,tp,LOCATION_MZONE,0,nil,c)
	end
	local mat=rmg:FilterSelect(tp,this.matfilter2,1,1,nil,c:GetRank())
	c:SetMaterial(mat)
	Duel.Overlay(c,mat)
end

