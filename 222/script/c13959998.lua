--Design/Image/Script: wyykak
c13959997={}
Duel.LoadScript("c13959997.lua")

local cc=13959998
local this=_G["c"..cc]
local rerollc={76815942,17994645,55863245,44155002,68319538,7391448,75326861,34408491,24221808,87460579,40939228,21123811}

this.maincount=40
this.extracount=20
this.useBanList=true
this.skillEnabled=false
this.CardList={}
this.clCode=13959996

function this.initial_effect(c)
	if not this.gc then
		this.gc=true
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE_START|PHASE_DRAW)
		e1:SetCondition(this.con)
		e1:SetOperation(this.op)
		Duel.RegisterEffect(e1,0)
		local es1=Effect.CreateEffect(c)
		es1:SetType(EFFECT_TYPE_FIELD)
		es1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		es1:SetCode(EFFECT_SKIP_DP)
		es1:SetTargetRange(1,1)
		es1:SetCondition(this.con1)
		Duel.RegisterEffect(es1,0)
		local es2=es1:Clone()
		es2:SetCode(EFFECT_SKIP_SP)
		es2:SetCondition(this.con2)
		Duel.RegisterEffect(es2,0)
		local es3=es2:Clone()
		es3:SetCode(EFFECT_SKIP_M1)
		Duel.RegisterEffect(es3,0)
		local es6=es1:Clone()
		es6:SetCode(EFFECT_CANNOT_BP)
		es6:SetCondition(this.con3)
		Duel.RegisterEffect(es6,0)
		local es7=es2:Clone()
		es7:SetCode(EFFECT_CANNOT_ACTIVATE)
		es7:SetValue(aux.TRUE)
		Duel.RegisterEffect(es7,0)
		local es8=Effect.CreateEffect(c)
		es8:SetType(EFFECT_TYPE_FIELD)
		es8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_IGNORE_RANGE)
		es8:SetTargetRange(0xff,0xff)
		es8:SetCode(EFFECT_DISABLE)
		es8:SetCondition(this.con4)
		Duel.RegisterEffect(es8,0)
		local es9=es7:Clone()
		es9:SetCondition(this.con5)
		Duel.RegisterEffect(es9,0)
		Duel.RegisterFlagEffect(0,cc,0,0,1)
		Duel.RegisterFlagEffect(1,cc,0,0,1)
		local es10=es1:Clone()
		es10:SetCode(EFFECT_DRAW_COUNT)
		es10:SetValue(0)
		es10:SetCondition(this.con6)
		Duel.RegisterEffect(es10,0)
	end
end

function this.con6()
	return this.isTag and Duel.GetTurnCount()==3
end

function this.con1()
	return this.isTag and ({false,true,false,true,true})[Duel.GetTurnCount()]
end
function this.con2()
	return this.isTag and ({true,true,true,true})[Duel.GetTurnCount()]
end
function this.con3()
	return this.isTag and ({true,true,true,true,true})[Duel.GetTurnCount()]
end

function this.con4()
	return this.isPicking
end

function this.con5()
	return Duel.GetCurrentPhase()==PHASE_DRAW and (Duel.GetTurnCount()==1 or (this.isTag and Duel.GetTurnCount()==3))
end

function this.con()
	return Duel.GetTurnCount()==1 or (this.isTag and Duel.GetTurnCount()==3)
end

function this.seed()
	local g=Group.CreateGroup()
	local gt={}
	for i=0,15 do
		local c=Duel.CreateToken(0,10000)
		gt[c]=i
		g:AddCard(c)
	end
	Duel.SendtoDeck(g,0,0,REASON_RULE)
	local result=0
	for i=0,7 do
		result=result+(gt[g:RandomSelect(0,1):GetFirst()]<<(4*i))
	end
	Duel.Exile(g,REASON_RULE)
	g:DeleteGroup()
	return result
end

function this.seed2()
	local result=0
	for i=0,31 do
		result=result+(Duel.TossCoin(0,1)<<i)
	end
	return result
end

function this.seed3()
	local result=0
	local g=Duel.GetFieldGroup(0,0xff,0xff):RandomSelect(0,8)
	local ct={}
	local c=g:GetFirst()
	for i=0,7 do
		ct[c]=i
		c=g:GetNext()
	end
	for i=0,10 do
		result=result+(ct[g:RandomSelect(0,1):GetFirst()]<<(3*i))
	end
	g:DeleteGroup()
	return result&0xffffffff
end

function this.saveDeck(tp)
	if not this.deckList then
		this.deckList={}
		this.extraList={}
	end
	this.deckList[tp]={}
	this.extraList[tp]={}
	local dl=this.deckList[tp]
	local el=this.extraList[tp]
	Duel.GetMatchingGroup(function(c) return c:GetOriginalCode()~=cc end,tp,LOCATION_DECK|LOCATION_HAND,0,nil):ForEach(function(c) dl[#dl+1]=c:GetOriginalCode() end)
	Duel.GetFieldGroup(tp,LOCATION_EXTRA,0):ForEach(function(c) el[#el+1]=c:GetOriginalCode() end)
end

function this.op(e,tp)
	this.isPicking=true
	if Duel.GetTurnCount()==1 then
		math.randomseed(this.seed3())
	end
	this.saveDeck(0)
	this.saveDeck(1)
	Duel.Exile(Duel.GetFieldGroup(0,LOCATION_DECK|LOCATION_EXTRA|LOCATION_HAND,LOCATION_DECK|LOCATION_EXTRA|LOCATION_HAND),REASON_RULE)
	if Duel.GetTurnCount()==1 then
		this.isTag=Duel.SelectYesNo(0,aux.Stringid(cc,8))
		if Duel.SelectYesNo(0,aux.Stringid(cc,2)) then
			Debug.Message("字段限制解除")
			this.setOverride()
		end
		if Duel.SelectYesNo(0,aux.Stringid(cc,4)) then
			Debug.Message("种族限制解除")
			this.raceOverride()
		end
		if Duel.SelectYesNo(0,aux.Stringid(cc,5)) then
			Debug.Message("属性限制解除")
			this.attrOverride()
		end
		if Duel.SelectYesNo(0,aux.Stringid(cc,9)) then
			Debug.Message("仪式强化已启用")
			this.ritualEnhance(e:GetHandler())
		end
		if Duel.SelectYesNo(0,aux.Stringid(13959997,3)) then
			this.skillEnabled=true
			Debug.Message("技能已启用")
		end
		if Duel.SelectYesNo(0,aux.Stringid(cc,14)) then
			if Duel.SelectYesNo(0,aux.Stringid(13959997,0)) then
				this.maincount=Duel.AnnounceLevel(0,1,10)*10
			end
			if Duel.SelectYesNo(0,aux.Stringid(13959997,1)) then
				this.extracount=Duel.AnnounceLevel(0,1,10)*10
			end
			this.useBanList=Duel.SelectYesNo(0,aux.Stringid(13959997,2))
			if Duel.SelectYesNo(0,aux.Stringid(13959997,6)) then
				this.clCode=({13959996,13959994})[Duel.SelectOption(0,aux.Stringid(13959997,7),aux.Stringid(13959997,8))+1]
			end
		end
		this.option=Duel.SelectOption(0,aux.Stringid(cc,0),aux.Stringid(cc,1),aux.Stringid(cc,6),aux.Stringid(cc,7),aux.Stringid(cc,11),aux.Stringid(cc,10),aux.Stringid(13959997,4),aux.Stringid(13959997,5))
		local n=0
		if this.option==0 then
			Debug.Message("本局决斗使用2pick规则")
			this.f=function() this.twopick(this.maincount,this.extracount) end
		elseif this.option==1 then
			Debug.Message("本局决斗使用自定义轮抽规则（类MTG）")
			Duel.Hint(0,HINT_SELECTMSG,aux.Stringid(cc,3))
			n=Duel.AnnounceLevel(0,2,12)
			this.f=function() this.custompick(this.maincount,this.extracount,n) end
		elseif this.option==2 then
			Debug.Message("本局决斗使用无竞争n选1规则")
			Duel.Hint(0,HINT_SELECTMSG,aux.Stringid(cc,3))
			n=Duel.AnnounceLevel(0,2,12)
			this.f=function() this.npick(this.maincount,this.extracount,n) end
		elseif this.option==3 then
			Debug.Message("本局决斗使用整组2pick规则")
			Duel.Hint(0,HINT_SELECTMSG,aux.Stringid(cc,3))
			n=Duel.AnnounceLevel(0,1,10)
			this.f=function() this.twopickn(this.maincount,this.extracount,n) end
		elseif this.option==4 then
			Debug.Message("本局决斗使用全随机规则")
			this.f=function() this.fullrandom(this.maincount,this.extracount) end
		elseif this.option==5 then
			Debug.Message("本局决斗使用20张场上轮选规则")
			Duel.Hint(0,HINT_SELECTMSG,aux.Stringid(cc,3))
			n=Duel.AnnounceLevel(0)
			this.f=function() this.fpick(this.maincount,this.extracount,n) end
		elseif this.option==6 then
			Debug.Message("本局决斗使用部分随机规则")
			n=Duel.AnnounceLevel(0,1,10)
			this.f=function() this.partialrandom(n) end
		elseif this.option==7 then
			Debug.Message("本局决斗使用部分卡组交换规则")
			n=Duel.AnnounceLevel(0,1,10)
			this.f=function() this.swapmode(n) end
		end
	end
	this.f()
	Duel.ConfirmCards(0,Duel.GetFieldGroup(0,LOCATION_DECK,0))
	Duel.ConfirmCards(1,Duel.GetFieldGroup(1,LOCATION_DECK,0))
	Duel.SelectMatchingCard(0,nil,0,LOCATION_EXTRA,0,0,99,nil)
	Duel.SelectMatchingCard(1,nil,1,LOCATION_EXTRA,0,0,99,nil)
	if this.skillEnabled then
		Duel.SendtoDeck(Duel.CreateToken(0,Duel.AnnounceCard(0,0xe39,OPCODE_ISSETCARD)),0,0,REASON_RULE)
		Duel.SendtoDeck(Duel.CreateToken(1,Duel.AnnounceCard(1,0xe39,OPCODE_ISSETCARD)),1,0,REASON_RULE)
	end
	Duel.ShuffleDeck(0)
	Duel.ShuffleDeck(1)
	Duel.ShuffleExtra(0)
	Duel.ShuffleExtra(1)

	if not this.isTag or Duel.GetTurnCount()==5 then
		this.isPicking=false
	end
	Duel.Draw(0,5,REASON_RULE)
	Duel.Draw(1,5,REASON_RULE)
	this.reroll(0)
	this.reroll(1)
	this.isPicking=false
	Duel.ResetTimeLimit(0)
	Duel.ResetTimeLimit(1)
end

function this.ccGen(from,count)
	if not this.CardList.Main then
		local ml,el,mat,eat=c13959997.loadCardList(this.useBanList,false,this.clCode)
		this.CardList.Main=ml
		this.CardList.Extra=el
		this.CardList.MainAliasTable=mat
		this.CardList.ExtraAliasTable=eat
	end
	local g={}
	for i=1,count do
		local temp=this.CardList[from][math.random(1,#this.CardList[from])]
		local at=this.CardList[from.."AliasTable"]
		if #at[temp]>1 then
			g[i]=at[temp][math.random(1,#at[temp])]
		else
			g[i]=temp
		end
	end
	return g
end

function this.ccSelect(g,tp)
	local cg=Group.CreateGroup()
	for k,v in pairs(g) do
		local c=Duel.CreateToken(tp,v)
		c:RegisterFlagEffect(cc,0,0,0,k)
		cg:AddCard(c)
	end
	local result
	if #cg>1 then
		result=cg:Select(tp,1,1,nil):GetFirst()
	else
		result=cg:GetFirst()
	end
	table.remove(g,result:GetFlagEffectLabel(cc))
	cg:DeleteGroup()
	return result
end
	
function this.twopick(mainc,extrac)
	local count=0
	while count<mainc do
		local g=this.ccGen("Main",2)
		local tp=count%2
		local c=this.ccSelect(g,tp)
		local c1=c
		local c2=Duel.CreateToken(1-tp,g[1])
		Duel.SendtoDeck(c1,tp,0,REASON_RULE)
		Duel.SendtoDeck(c2,1-tp,0,REASON_RULE)
		-- Duel.ConfirmCards(tp,c1)
		Duel.ConfirmCards(1-tp,c2)
		count=count+1
	end
	count=0
	while count<extrac do
		local g=this.ccGen("Extra",2)
		local tp=count%2
		local c=this.ccSelect(g,tp)
		local c1=c
		local c2=Duel.CreateToken(1-tp,g[1])
		Duel.SendtoDeck(c1,tp,0,REASON_RULE)
		Duel.SendtoDeck(c2,1-tp,0,REASON_RULE)
		-- Duel.ConfirmCards(tp,c1)
		Duel.ConfirmCards(1-tp,c2)
		count=count+1
	end
end

function this.custompick(mainc,extrac,packc)
	local count=0
	local packs={}
	local packnum=8*mainc//packc
	if mainc%packc~=0 then packnum=packnum+1 end
	for i=1,packnum do
		packs[i]=this.ccGen("Main",packc)
	end
	local cp=1
	while count<mainc do
		local tp=0
		while #packs[cp]==0 do
			if cp==packnum then
				cp=1
			else
				cp=cp+1
			end
		end
		local c1=this.ccSelect(packs[cp],tp)
		while #packs[cp]==0 do
			if cp==packnum then
				cp=1
			else
				cp=cp+1
			end
		end
		local c2=this.ccSelect(packs[cp],1-tp)
		Duel.SendtoDeck(c1,tp,0,REASON_RULE)
		Duel.SendtoDeck(c2,1-tp,0,REASON_RULE)
		-- Duel.ConfirmCards(tp,c1)
		-- Duel.ConfirmCards(1-tp,c2)
		count=count+1
		if cp==packnum then 
			cp=1
		else
			cp=cp+1
		end
	end
	count=0
	packs={}
	packnum=8*extrac//packc
	if extrac%packc~=0 then packnum=packnum+1 end
	for i=1,packnum do
		packs[i]=this.ccGen("Extra",packc)
	end
	cp=1
	while count<extrac do
		local tp=0
		while #packs[cp]==0 do
			if cp==packnum then
				cp=1
			else
				cp=cp+1
			end
		end
		local c1=this.ccSelect(packs[cp],tp)
		while #packs[cp]==0 do
			if cp==packnum then
				cp=1
			else
				cp=cp+1
			end
		end
		local c2=this.ccSelect(packs[cp],1-tp)
		Duel.SendtoDeck(c1,tp,0,REASON_RULE)
		Duel.SendtoDeck(c2,1-tp,0,REASON_RULE)
		-- Duel.ConfirmCards(tp,c1)
		-- Duel.ConfirmCards(1-tp,c2)
		count=count+1
		if cp==packnum then 
			cp=1
		else
			cp=cp+1
		end
	end
end

function this.setOverride()
	Card.IsSetCard=aux.TRUE
	Card.IsPreviousSetCard=aux.TRUE
	Card.IsFusionSetCard=aux.TRUE
	Card.IsLinkSetCard=aux.TRUE
	Card.IsOriginalSetCard=aux.TRUE
end

function this.raceOverride()
	Card.IsRace=function(c) return c and c:IsType(TYPE_MONSTER) end
	Card.IsLinkRace=function(c) return c and c:IsType(TYPE_MONSTER) end
	Card.GetRace=function(c) if c and c:IsType(TYPE_MONSTER) then return RACE_ALL end return nil end
	Card.GetLinkRace=function(c) if c and c:IsType(TYPE_MONSTER) then return RACE_ALL end return nil end
	Card.GetOriginalRace=function(c) if c and c:GetOriginalType()&TYPE_MONSTER>0 then return RACE_ALL end return nil end
end

function this.attrOverride()
	Card.IsAttribute=function(c) return c and c:IsType(TYPE_MONSTER) end
	Card.IsFusionAttribute=function(c) return c and c:IsType(TYPE_MONSTER) end
	Card.IsLinkAttribute=function(c) return c and c:IsType(TYPE_MONSTER) end
	Card.GetAttribute=function(c) if c and c:IsType(TYPE_MONSTER) then return 0x7f end return nil end
	Card.GetFusionAttribute=function(c) if c and c:IsType(TYPE_MONSTER) then return 0x7f end return nil end
	Card.GetLinkAttribute=function(c) if c and c:IsType(TYPE_MONSTER) then return 0x7f end return nil end
	Card.GetOriginalAttribute=function(c) if c and c:GetOriginalType()&TYPE_MONSTER>0 then return 0x7f end return nil end
end

function this.ritualEnhance(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_RITUAL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_IGNORE_RANGE)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(function(e,c1) return c1:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER end)
	Duel.RegisterEffect(e1,0)
	
	local e2=aux.AddRitualProcUltimate(c,
		function(c1,e,tp) return c1==e:GetHandler() end,
		Card.GetLevel,
		"Greater",
		LOCATION_HAND,
		nil,
		nil)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetDescription(aux.Stringid(cc,13))
	
	local reg=Effect.CreateEffect(c)
	reg:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	reg:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_IGNORE_RANGE)
	reg:SetTargetRange(0xff,0xff)
	reg:SetTarget(function(e,c1) return c1:GetOriginalType()&(TYPE_RITUAL|TYPE_MONSTER)==(TYPE_RITUAL|TYPE_MONSTER) end)
	reg:SetLabelObject(e2)
	Duel.RegisterEffect(reg,0)
end

function this.ccEnhance(c,n)
	local ccop=function(e,tp,eg,ep,ev,re,r,rp)
		local tgc=Duel.AnnounceCard(tp)
		local ce=Effect.CreateEffect(e:GetHandler())
		ce:SetType(EFFECT_TYPE_SINGLE)
		ce:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_IGNORE_RANGE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
		ce:SetCode(EFFECT_CHANGE_CODE)
		ce:SetValue(tgc)
		e:GetHandler():RegisterEffect(ce)
		Duel.BreakEffect()
		if Duel.SelectYesNo(tp,aux.Stringid(13959997,5)) then
			Duel.SendtoDeck(e:GetHandler(),tp,2,REASON_EFFECT)
		end
	end
		
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(13959997,4))
	e1:SetRange(LOCATION_ONFIELD|LOCATION_HAND)
	e1:SetCountLimit(n,13959998|EFFECT_COUNT_CODE_DUEL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(ccop)
	
	local reg=Effect.CreateEffect(c)
	reg:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	reg:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_IGNORE_RANGE)
	reg:SetTargetRange(0xff,0xff)
	reg:SetTarget(aux.TRUE)
	reg:SetLabelObject(e1)
	Duel.RegisterEffect(reg,0)
end

function this.npick(mainc,extrac,n)
	local count=0
	while count<mainc do
		local g1=this.ccGen("Main",n)
		local g2=this.ccGen("Main",n)
		local c1=this.ccSelect(g1,0)
		local c2=this.ccSelect(g2,1)
		Duel.SendtoDeck(c1,0,0,REASON_RULE)
		Duel.SendtoDeck(c2,1,0,REASON_RULE)
		-- Duel.ConfirmCards(0,c1)
		-- Duel.ConfirmCards(1,c2)
		count=count+1
	end
	count=0
	while count<extrac do
		local g1=this.ccGen("Extra",n)
		local g2=this.ccGen("Extra",n)
		local c1=this.ccSelect(g1,0)
		local c2=this.ccSelect(g2,1)
		Duel.SendtoDeck(c1,0,0,REASON_RULE)
		Duel.SendtoDeck(c2,1,0,REASON_RULE)
		-- Duel.ConfirmCards(0,c1)
		-- Duel.ConfirmCards(1,c2)
		count=count+1
	end
end

function this.fSelect(tp,g1,g2)
	local cg1,cg2=this.displayOnField(tp,g1,g2)
	local cg=Group.CreateGroup(cg1,cg2)
	if cg1:IsContains(cg:Select(tp,1,1,nil):GetFirst()) then
		Duel.Exile(cg2,REASON_RULE)
		cg2:DeleteGroup()
		cg:DeleteGroup()
		return cg1
	else
		Duel.Exile(cg1,REASON_RULE)
		cg1:DeleteGroup()
		cg:DeleteGroup()
		return cg2
	end
end

function this.displayOnField(tp,g1,g2)
	local cg1=Group.CreateGroup()
	local cg2=Group.CreateGroup()
	local ct1={}
	local ct2={}
	for k,v in pairs(g1) do
		if k>10 then break end
		local c=Duel.CreateToken(tp,v)
		if k<=5 then
			Duel.MoveToField(c,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,false,1<<(k-1))
		else
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,false,1<<(k-6))
		end
		cg1:AddCard(c)
		ct1[c]=v
	end
	for k,v in pairs(g2) do
		if k>10 then break end
		local c=Duel.CreateToken(tp,v)
		if k<=5 then
			Duel.MoveToField(c,tp,1-tp,LOCATION_MZONE,POS_FACEUP_ATTACK,false,1<<(k-1))
		else
			Duel.MoveToField(c,tp,1-tp,LOCATION_SZONE,POS_FACEUP,false,1<<(k-6))
		end
		cg2:AddCard(c)
		ct2[c]=v
	end
	return cg1,cg2,ct1,ct2
end

function this.twopickn(mainc,extrac,n)
	local count=0
	while count<mainc do
		local g11=this.ccGen("Main",n)
		local g12=this.ccGen("Main",n)
		local g21=this.ccGen("Main",n)
		local g22=this.ccGen("Main",n)
		local c1=this.fSelect(0,g11,g12)
		Duel.SendtoDeck(c1,0,0,REASON_RULE)
		local c2=this.fSelect(1,g21,g22)
		Duel.SendtoDeck(c2,1,0,REASON_RULE)
		-- Duel.ConfirmCards(0,c1)
		-- Duel.ConfirmCards(1,c2)
		count=count+n
	end
	count=0
	while count<extrac do
		local g11=this.ccGen("Extra",n)
		local g12=this.ccGen("Extra",n)
		local g21=this.ccGen("Extra",n)
		local g22=this.ccGen("Extra",n)
		local c1=this.fSelect(0,g11,g12)
		Duel.SendtoDeck(c1,0,0,REASON_RULE)
		local c2=this.fSelect(1,g21,g22)
		Duel.SendtoDeck(c2,1,0,REASON_RULE)
		-- Duel.ConfirmCards(0,c1)
		-- Duel.ConfirmCards(1,c2)
		count=count+n
	end
end

function this.fpick(mainc,extrac,n)
	local change=function(c,ct,from)
		local ncc=this.ccGen(from,1)[1]
		ct[c]=ncc
		c:SetEntityCode(ncc,true)
	end
	local count=0
	local reroll={}
	reroll[0]=n
	reroll[1]=n
	local rerollCard={}
	rerollCard[0]=Duel.CreateToken(0,rerollc[reroll[0]])
	rerollCard[1]=Duel.CreateToken(1,rerollc[reroll[1]])
	Duel.SendtoHand(rerollCard[0],0,REASON_RULE)
	Duel.SendtoHand(rerollCard[1],1,REASON_RULE)
	Duel.MoveToField(rerollCard[0],0,0,LOCATION_MZONE,POS_FACEUP_ATTACK,false,1<<5)
	Duel.MoveToField(rerollCard[1],1,1,LOCATION_MZONE,POS_FACEUP_ATTACK,false,1<<5)
	local g1=this.ccGen("Main",10)
	local g2=this.ccGen("Main",10)
	local cg1,cg2,ct1,ct2=this.displayOnField(0,g1,g2)
	local tp=0
	local rerolled=false
	while count<mainc do
		local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE|LOCATION_SZONE,LOCATION_MZONE|LOCATION_SZONE)
		if rerollCard[1-tp] then
			sg:RemoveCard(rerollCard[1-tp])
		end
		if rerollCard[tp] and rerolled then
			sg:RemoveCard(rerollCard[tp])
		end
		local sc=sg:Select(tp,1,1,nil):GetFirst()
		if sc==rerollCard[tp] then
			cg1:ForEach(change,ct1,"Main")
			cg2:ForEach(change,ct2,"Main")
			rerolled=true
			reroll[tp]=reroll[tp]-1
			if reroll[tp]==0 then
				Duel.Exile(rerollCard[tp],REASON_RULE)
				rerollCard[tp]=nil
			else
				rerollCard[tp]:SetEntityCode(rerollc[reroll[tp]],true)
			end
		else
			if ct1[sc] then
				Duel.SendtoDeck(Duel.CreateToken(tp,ct1[sc]),tp,0,REASON_RULE)
				change(sc,ct1,"Main")
			else
				Duel.SendtoDeck(Duel.CreateToken(tp,ct2[sc]),tp,0,REASON_RULE)
				change(sc,ct2,"Main")
			end
			if tp==1 then
				count=count+1
			end
			tp=1-tp
			rerolled=false
		end
	end
	cg1:ForEach(change,ct1,"Extra")
	cg2:ForEach(change,ct2,"Extra")
	tp=0
	count=0
	rerolled=false
	while count<extrac do
		local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE|LOCATION_SZONE,LOCATION_MZONE|LOCATION_SZONE)
		if rerollCard[1-tp] then
			sg:RemoveCard(rerollCard[1-tp])
		end
		if rerollCard[tp] and rerolled then
			sg:RemoveCard(rerollCard[tp])
		end
		local sc=sg:Select(tp,1,1,nil):GetFirst()
		if sc==rerollCard[tp] then
			cg1:ForEach(change,ct1,"Extra")
			cg2:ForEach(change,ct2,"Extra")
			rerolled=true
			reroll[tp]=reroll[tp]-1
			if reroll[tp]==0 then
				Duel.Exile(rerollCard[tp],REASON_RULE)
				rerollCard[tp]=nil
			else
				rerollCard[tp]:SetEntityCode(rerollc[reroll[tp]],true)
			end
		else
			if ct1[sc] then
				Duel.SendtoDeck(Duel.CreateToken(tp,ct1[sc]),tp,0,REASON_RULE)
				change(sc,ct1,"Extra")
			else
				Duel.SendtoDeck(Duel.CreateToken(tp,ct2[sc]),tp,0,REASON_RULE)
				change(sc,ct2,"Extra")
			end
			if tp==1 then
				count=count+1
			end
			tp=1-tp
			rerolled=false
		end
	end
	Duel.Exile(Duel.GetFieldGroup(0,LOCATION_MZONE|LOCATION_SZONE,LOCATION_MZONE|LOCATION_SZONE),REASON_RULE)
end

function this.fullrandom(mainc,extrac)
	for i=0,1 do
		Duel.SelectYesNo(i,aux.Stringid(cc,15))
		local mg=Group.CreateGroup()
		local eg=Group.CreateGroup()
		for _,v in pairs(this.ccGen("Main",mainc)) do
			mg:AddCard(Duel.CreateToken(i,v))
		end
		Duel.SendtoDeck(mg,i,0,REASON_RULE)
		for _,v in pairs(this.ccGen("Extra",extrac)) do
			eg:AddCard(Duel.CreateToken(i,v))
		end
		Duel.SendtoDeck(eg,i,0,REASON_RULE)
		mg:DeleteGroup()
		eg:DeleteGroup()
		Duel.SelectYesNo(i,aux.Stringid(cc,15))
	end
end

function this.reroll(tp)
	local ct=3
	while ct>0 and Duel.SelectYesNo(tp,aux.Stringid(cc,12)) do
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		Duel.SendtoDeck(g,tp,0,REASON_RULE)
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,#g-1,REASON_RULE)
		ct=ct-1
	end
end

function this.picrandom(g)
	if not this.CardList.Main then
		local ml,el,mat,eat=c13959997.loadCardList(this.useBanList,false,this.clCode)
		this.CardList.Main=ml
		this.CardList.Extra=el
		this.CardList.MainAliasTable=mat
		this.CardList.ExtraAliasTable=eat
	end
	local rg={}
	for _,v in pairs(g) do
		if this.CardList.MainAliasTable[v] then
			local at=this.CardList.MainAliasTable
			rg[#rg+1]=at[v][math.random(1,#at[v])]
		elseif this.CardList.ExtraAliasTable[v] then
			local at=this.CardList.ExtraAliasTable
			rg[#rg+1]=at[v][math.random(1,#at[v])]
		else
			rg[#rg+1]=v
		end
	end
	return rg
end

function this.sample(g,ct)
	local cct=#g
	local rg={}
	local remains={}
	for i=1,ct do
		if i>cct then
			break
		end
		local idx=math.random(1,cct-i+1)
		
		rg[#rg+1]=g[idx]
		if idx<cct-i+1 then
			g[idx]=g[cct-i+1]
		end
	end
	for i=1,cct-ct do
		remains[i]=g[i]
	end
	return rg,remains
end

function this.partialrandom(n)
	for i=0,1 do
		Duel.SelectYesNo(i,aux.Stringid(cc,15))
		local mg=Group.CreateGroup()
		local eg=Group.CreateGroup()
		local mc=math.floor(#this.deckList[i]*n/10)
		local ec=math.floor(#this.extraList[i]*n/10)
		for _,v in pairs(this.picrandom(this.sample(this.deckList[i],mc))) do
			mg:AddCard(Duel.CreateToken(i,v))
		end
		for _,v in pairs(this.ccGen("Main",#this.deckList[i]-mc)) do
			mg:AddCard(Duel.CreateToken(i,v))
		end
		Duel.SendtoDeck(mg,i,0,REASON_RULE)
		for _,v in pairs(this.picrandom(this.sample(this.extraList[i],ec))) do
			eg:AddCard(Duel.CreateToken(i,v))
		end
		for _,v in pairs(this.ccGen("Extra",#this.extraList[i]-ec)) do
			eg:AddCard(Duel.CreateToken(i,v))
		end
		Duel.SendtoDeck(eg,i,0,REASON_RULE)
		mg:DeleteGroup()
		eg:DeleteGroup()
		Duel.SelectYesNo(i,aux.Stringid(cc,15))
	end
end

function this.swapmode(n)
	local mg={}
	local eg={}
	mg[0]=Group.CreateGroup()
	mg[1]=Group.CreateGroup()
	eg[0]=Group.CreateGroup()
	eg[1]=Group.CreateGroup()
	for i=0,1 do
		local mcg,mcgr=this.sample(this.deckList[i],math.floor(#this.deckList[i]*n/10))
		local ecg,ecgr=this.sample(this.extraList[i],math.floor(#this.extraList[i]*n/10))
		for _,v in pairs(mcg) do
			mg[1-i]:AddCard(Duel.CreateToken(1-i,v))
		end
		for _,v in pairs(mcgr) do
			mg[i]:AddCard(Duel.CreateToken(i,v))
		end
		for _,v in pairs(ecg) do
			eg[1-i]:AddCard(Duel.CreateToken(1-i,v))
		end
		for _,v in pairs(ecgr) do
			eg[i]:AddCard(Duel.CreateToken(i,v))
		end
	end
	for i=0,1 do
		Duel.SelectYesNo(i,aux.Stringid(cc,15))
		Duel.SendtoDeck(mg[i],i,0,REASON_RULE)
		Duel.SendtoDeck(eg[i],i,0,REASON_RULE)
		Duel.SelectYesNo(i,aux.Stringid(cc,15))
	end
end