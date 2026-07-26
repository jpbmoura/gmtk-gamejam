extends Node

var failures := 0

func check(label: String, condition: bool) -> void:
	if condition:
		print("  OK   %s" % label)
	else:
		failures += 1
		print("  FAIL %s" % label)

func _ready() -> void:
	SaveSystem.wipe()

	print("-- estado inicial --")
	check("sem coins", Global.coins == 0)
	check("sem dash", not Global.can_dash())
	check("sem double jump", not Global.can_double_jump())
	check("sem wall jump", not Global.can_wall_jump())

	print("-- catalogo --")
	check("3 itens", Global.CATALOG.size() == 3)
	check("double_jump custa 5", Global.CATALOG["double_jump"].cost == 5)
	check("wall_jump custa 15", Global.CATALOG["wall_jump"].cost == 15)
	check("dash custa 15", Global.CATALOG["dash"].cost == 15)

	print("-- compra sem saldo --")
	check("buy falha sem coins", not Global.buy("double_jump", 5))
	check("continua sem double jump", not Global.can_double_jump())

	print("-- coleta de coins --")
	for i in 35:
		Global.add_coins(1)
	check("35 coins", Global.coins == 35)

	print("-- compras --")
	check("compra double jump", Global.buy("double_jump", 5))
	check("debitou o custo", Global.coins == 30)
	check("double jump ligado", Global.can_double_jump())
	check("dash ainda desligado", not Global.can_dash())
	check("nao compra de novo (max_level)", not Global.buy("double_jump", 5))
	check("saldo intacto apos recusa", Global.coins == 30)

	check("compra wall jump", Global.buy("wall_jump", 15))
	check("compra dash", Global.buy("dash", 15))
	check("saldo zerado", Global.coins == 0)
	check("as 3 habilidades ligadas",
		Global.can_dash() and Global.can_double_jump() and Global.can_wall_jump())

	print("-- fim de run nao apaga o progresso --")
	Global.reset_values()
	check("coins persistem", Global.coins == 0)
	check("habilidades persistem",
		Global.can_dash() and Global.can_double_jump() and Global.can_wall_jump())

	print("-- persistencia em disco --")
	SaveSystem.save_game()
	SaveSystem.coins = 999
	SaveSystem.upgrades = {}
	SaveSystem.load_game()
	check("coins vieram do disco", SaveSystem.coins == 0)
	check("upgrades vieram do disco",
		SaveSystem.has_upgrade("dash")
		and SaveSystem.has_upgrade("double_jump")
		and SaveSystem.has_upgrade("wall_jump"))

	print("-- upgrade temporario do altar --")
	SaveSystem.wipe()
	Global.altar_give_dash_upgrade()
	check("altar liga o dash", Global.can_dash())
	check("altar nao grava no save", not SaveSystem.has_upgrade("dash"))
	Global.reset_values()
	check("altar expira no fim da run", not Global.can_dash())

	await _test_balloon()
	await _test_death()

	SaveSystem.wipe()
	print("\n%s (%d falhas)" % ["PASSOU" if failures == 0 else "FALHOU", failures])
	get_tree().quit(failures)


func _test_balloon() -> void:
	print("-- balao do merchant --")
	var merchant: Area2D = load("res://scenes/merchant/merchant.tscn").instantiate()
	merchant.shop_ui = load("res://scenes/merchant/shop_ui.tscn").instantiate()
	add_child(merchant.shop_ui)
	add_child(merchant)
	await get_tree().process_frame

	var balloon: Panel = merchant.get_node("Balloon")
	var prompt: Label = merchant.get_node("Prompt")
	check("texto correto", balloon.get_node("Label").text == "Spend Coins Here!")
	check("balao visivel de longe", balloon.visible)
	check("prompt escondido de longe", not prompt.visible)

	var body := CharacterBody2D.new()
	body.add_to_group("player")
	merchant._on_body_entered(body)
	check("balao some no raio", not balloon.visible)
	check("prompt aparece no raio", prompt.visible)

	merchant._on_body_exited(body)
	check("balao volta ao sair", balloon.visible)
	check("prompt some ao sair", not prompt.visible)

	body.free()
	merchant.queue_free()


func _test_death() -> void:
	print("-- morrer encerra a run igual o tempo acabar --")
	Global.reset_values()
	Global.start_timer(30.0)
	check("timer rodando apos a placa", Global.timer_running and Global.timer_started)

	var died := [false]
	Global.player_died.connect(func() -> void: died[0] = true, CONNECT_ONE_SHOT)
	GameManager.run_active = true
	GameManager.kill_player()
	await get_tree().process_frame

	check("tempo zerado", Global.time_left == 0.0)
	check("timer parado", not Global.timer_running)
	check("destravado pra placa religar", not Global.timer_started)
	check("avisou pra recarregar a fase", died[0])

	# a placa de inicio consegue religar o cronometro na proxima tentativa
	Global.start_timer(30.0)
	check("placa religa o timer", Global.timer_running and Global.time_left == 30.0)
	Global.reset_values()
