--2Pick技能-融合强化
--By wyykak

if not c13959997 then
	c13959997={}
	Duel.LoadScript("c13959997.lua")
end
local tpu=c13959997

local cc=13959981
local this=_G["c"..cc]

function this.initial_effect(c)
	local e1=tpu.createSkill(c,cc,3,aux.Stringid(cc,0),false)
	e1:SetTarget(this.tg1)
	e1:SetCost(this.cost1)
	e1:SetOperation(this.op1)
	e1:SetCategory(CATEGORY_TOHAND)
	c:RegisterEffect(e1)
	
	local e2=tpu.createSkill(c,cc-10,1,aux.Stringid(cc,1),false)
	e2:SetCost(this.cost2)
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

function this.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLP(tp)>=1000 and Duel.IsExistingMatchingCard(function(c) return c:IsDiscardable() end,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.PayLPCost(tp,1000)
	Duel.SendtoGrave(Duel.SelectMatchingCard(tp,function(c) return c:IsDiscardable() end,tp,LOCATION_HAND,0,1,1,nil),REASON_COST|REASON_DISCARD)
end

function this.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanSendtoHand(tp)
	end
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
end

function this.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.CreateToken(tp,24094653)
	Duel.SendtoHand(tc,tp,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
end

function this.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_EXTRA,0,nil,POS_FACEDOWN)
	if chk==0 then
		return not g:IsExists(function(c) return c:IsType(TYPE_FUSION) and c:IsType(TYPE_MONSTER) and not c:IsAbleToRemoveAsCost(POS_FACEDOWN) end,1,nil)
	end
	Duel.Remove(g:Filter(function(c) return not (c:IsType(TYPE_FUSION) and c:IsType(TYPE_MONSTER)) end,nil),POS_FACEDOWN,REASON_COST)
end

function this.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanSendtoHand(tp)
	end
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
end

function this.op2(e,tp,eg,ep,ev,re,r,rp)
	getmetatable(e:GetHandler()).announce_filter={0x46,OPCODE_ISSETCARD}
	local tc=Duel.CreateToken(tp,Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter)))
	Duel.SendtoHand(tc,tp,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(aux.exccon)
	e1:SetCost(this.cost3)
	e1:SetTarget(this.tg3)
	e1:SetOperation(this.op3)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(cc,3))
	tc:RegisterEffect(e1)
end

function this.costfilter3(c)
	return c:IsType(TYPE_FUSION) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function this.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(this.costfilter3,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Remove(Duel.SelectMatchingCard(tp,this.costfilter3,tp,LOCATION_GRAVE,0,1,1,nil),POS_FACEUP,REASON_COST)
end

function this.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToHand()
	end
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_GRAVE)
end

function this.op3(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
	end
end