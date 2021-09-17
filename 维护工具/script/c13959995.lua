--2pick Maintenance Utility
c13959997={}
Duel.LoadScript("c13959997.lua")
tpu=c13959997
cl=c13959996

local cc=13959995
local this=_G["c"..cc]

function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CANNOT_INACTIVATE|EFFECT_FLAG_CANNOT_NEGATE|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL|EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE|LOCATION_SZONE|LOCATION_GRAVE|LOCATION_REMOVED)
	e1:SetOperation(this.op1)
	c:RegisterEffect(e1)
end

function this.ccSelect(tp,g)
	local cg=Group.CreateGroup()
	local ct={}
	for k,v in pairs(g) do
		local c=Duel.CreateToken(tp,v)
		ct[c]=v
		cg:AddCard(c)
	end
	local sel=cg:Select(tp,0,#cg,nil)
	local result={}
	sel:ForEach(function(c1) result[#result+1]=ct[c1] end)
	cg:DeleteGroup()
	return result
end

function this.op1(e,tp)
	local ml,el,mat,eat=tpu.loadCardList(false,true)
	Debug.Message("已从c13959996.lua加载卡表")
	Debug.Message("主卡组数量："..#ml)
	Debug.Message("额外卡组数量："..#el)
	local quit=false
	while not quit do
		local opts={}
		for i=0,8 do
			opts[i+1]=aux.Stringid(cc,i)
		end
		local option=Duel.SelectOption(tp,table.unpack(opts))
		if option==0 then
			tpu.writeList(tpu.toList(tpu.toSet(ml)),"2pick/cardlist.main.txt")
			tpu.writeList(tpu.toList(tpu.toSet(el)),"2pick/cardlist.extra.txt")
		elseif option==1 then
			ml=tpu.loadList("2pick/cardlist.main.txt")
			el=tpu.loadList("2pick/cardlist.extra.txt")
		elseif option==2 then
			tpu.writeList(tpu.toList(tpu.loadSet(cl.BlackList)),"2pick/blacklist.txt")
		elseif option==3 then
			cl.BlackList=tpu.dumpSet(tpu.toSet(tpu.loadList("2pick/blacklist.txt")))
		elseif option==4 then
			tpu.writeList(tpu.toList(tpu.loadSet(cl.BanList)),"2pick/banlist.txt")
		elseif option==5 then
			cl.BanList=tpu.dumpSet(tpu.toSet(tpu.loadList("2pick/banlist.txt")))
		elseif option==6 then
			Debug.Message("正在刷新卡表……")
			local nml={}
			local nel={}
			local nmat={}
			local neat={}
			for i=10000,99999999 do
				local cc,ca,ctype=Duel.ReadCard(i,CARDDATA_CODE,CARDDATA_ALIAS,CARDDATA_TYPE)
				if cc then
					local dif=cc-ca
					local real=0
					if dif>-10 and dif<10 then
						real=ca
					else
						real=cc
					end
					local at=0
					if ctype&TYPE_TOKEN==0 then
						if ctype&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)>0 then
							at=neat
						else
							at=nmat
						end
						if not at[real] then
							at[real]={}
						end
						at[real][#at[real]+1]=cc
					end
				end
			end
			local bldelCount=0
			local blldelCount=0
			local ms=tpu.toSet(ml)
			local es=tpu.toSet(el)
			local bs=tpu.loadSet(cl.BanList)
			local bls=tpu.loadSet(cl.BlackList)
			local mdelta={}
			local edelta={}
			tpu.initSet(ms)
			tpu.initSet(es)
			tpu.initSet(bs)
			tpu.initSet(bls)
			for k,_ in pairs(nmat) do
				nml[#nml+1]=k
				if not ms:contains(k) then
					mdelta[#mdelta+1]=k
				else
					ms:del(k)
				end
			end
			for k,_ in pairs(neat) do
				nel[#nel+1]=k
				if not es:contains(k) then
					edelta[#edelta+1]=k
				else
					es:del(k)
				end
			end
			for _,v in pairs(tpu.toList(ms)) do
				if bs:contains(v) then
					bs:del(v)
					bldelCount=bldelCount+1
				end
				if bls:contains(v) then
					bls:del(v)
					blldelCount=blldelCount+1
				end
			end
			for _,v in pairs(tpu.toList(es)) do
				if bs:contains(v) then
					bs:del(v)
					bldelCount=bldelCount+1
				end
				if bls:contains(v) then
					bls:del(v)
					blldelCount=blldelCount+1
				end
			end
			Debug.Message("卡表扫描已完成")
			Debug.Message("主卡组数量："..#nml)
			Debug.Message("额外卡组数量："..#nel)
			Debug.Message("主卡组新增："..#mdelta)
			Debug.Message("额外卡组新增："..#edelta)
			Debug.Message("主卡组删除："..#tpu.toList(ms))
			Debug.Message("额外卡组删除："..#tpu.toList(es))
			Debug.Message("黑名单删除："..blldelCount)
			Debug.Message("禁卡表删除："..bldelCount)
			if Duel.SelectYesNo(tp,aux.Stringid(cc,9)) then
				Debug.Message("请选择需要加入黑名单的卡片")
				local ct=1
				local delta={}
				table.move(mdelta,1,#mdelta,1,delta)
				table.move(edelta,1,#edelta,#delta+1,delta)
				while ct<=#delta do
					local disp={}
					table.move(delta,ct,ct+4,1,disp)
					local sel=this.ccSelect(tp,disp)
					for _,v in pairs(sel) do
						bls:add(v)
					end
					ct=ct+5
				end
				Debug.Message("请选择需要加入禁卡表的卡片")
				ct=1
				while ct<=#delta do
					local disp={}
					table.move(delta,ct,ct+4,1,disp)
					local sel=this.ccSelect(tp,disp)
					for _,v in pairs(sel) do
						bs:add(v)
					end
					ct=ct+5
				end
			else
				tpu.writeList(mdelta,"2pick/delta.main.txt")
				tpu.writeList(edelta,"2pick/delta.extra.txt")
				Debug.Message("新增卡表已输出，请自行编辑黑名单和禁卡表")
			end
			ml=nml
			el=nel
			mat=nmat
			eat=neat
			cl.BlackList=tpu.dumpSet(bls)
			cl.BanList=tpu.dumpSet(bs)
		elseif option==7 then
			local fml={}
			local fel={}
			tpu.initSet(fml)
			tpu.initSet(fel)
			for _,v in pairs(ml) do
				for _,v2 in pairs(mat[v]) do
					fml:add(v2)
				end
			end
			for _,v in pairs(el) do
				for _,v2 in pairs(eat[v]) do
					fel:add(v2)
				end
			end
			cl.Main=tpu.dumpSet(fml)
			cl.Extra=tpu.dumpSet(fel)
			local f=io.open("2pick/c13959996.lua","w")
			f:write(this.template)
			f:write("this.Main=\""..cl.Main.."\"\n")
			f:write("this.Extra=\""..cl.Extra.."\"\n")
			f:write("this.BlackList=\""..cl.BlackList.."\"\n")
			f:write("this.BanList=\""..cl.BanList.."\"\n")
			f:flush()
			f:close()
		elseif option==8 then
			quit=true
		end
	end
end

this.template="--2pick Card List\n\nlocal cc=13959996\nlocal this=_G[\"c\"..cc]\n\nfunction this.initial_effect(c)\n\nend\n\n"
