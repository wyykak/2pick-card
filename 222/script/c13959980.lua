--2Pick技能-卡名变换
--By wyykak

if not c13959997 then
	c13959997={}
	Duel.LoadScript("c13959997.lua")
end
local tpu=c13959997

local cc=13959980
local this=_G["c"..cc]

function this.initial_effect(c)
	local e1=tpu.createSkill(c,cc,3,aux.Stringid(cc,0),false)
	e1:SetTarget(this.tg1)
	e1:SetOperation(this.op1)
	c:RegisterEffect(e1)
	
	local e2=tpu.createSkill(c,cc-10,1,aux.Stringid(cc,1),false)
	e2:SetTarget(this.tg2)
	e2:SetOperation(this.op2)
	e2:SetCategory(CATEGORY_TOHAND)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e3)
end

function this.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil)
	end
	e:SetLabel(Duel.AnnounceCard(tp))
	Duel.SetChainLimit(aux.FALSE)
end

function this.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	local ce=Effect.CreateEffect(e:GetHandler())
	ce:SetType(EFFECT_TYPE_SINGLE)
	ce:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_IGNORE_RANGE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
	ce:SetCode(EFFECT_CHANGE_CODE)
	ce:SetValue(e:GetLabel())
	tc:RegisterEffect(ce)
	Duel.BreakEffect()
	if Duel.SelectYesNo(tp,aux.Stringid(cc,2)) then
		Duel.SendtoDeck(tc,tp,2,REASON_EFFECT)
	end
end

function this.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanSendtoHand(tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND|LOCATION_ONFIELD,0)>0
	end
	Duel.SetChainLimit(aux.FALSE)
end

function this.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(Duel.GetFieldGroup(tp,LOCATION_HAND|LOCATION_ONFIELD,0),REASON_EFFECT)
	local g=Group.CreateGroup()
	for i=1,3 do
		g:Merge(Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,Duel.AnnounceCard(tp)))
	end
	Duel.SendtoHand(g,tp,REASON_EFFECT)
	if e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(cc,3)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		local ce=Effect.CreateEffect(e:GetHandler())
		ce:SetType(EFFECT_TYPE_SINGLE)
		ce:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_IGNORE_RANGE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
		ce:SetCode(EFFECT_CHANGE_CODE)
		ce:SetValue(Duel.AnnounceCard(tp))
		e:GetHandler():RegisterEffect(ce)
	end
end