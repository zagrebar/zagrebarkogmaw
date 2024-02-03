local menu = menu('zagrebar_kogmaw', 'zagrebar kogmaw')


menu:menu("Combo", "Combo");
menu.Combo:menu("Q", "KogMaw [Q]");
menu.Combo.Q:boolean("useQ", "Use Q In Combo", true);
menu.Combo.Q:slider("qMana", "Mana %", 0, 1, 100, 1);
menu.Combo.Q:boolean("qafteraa", "Q Only After Attack", true);

menu.Combo:menu("W", "KogMaw [W]");
menu.Combo.W:boolean("useW", "Use W In Combo", true);
menu.Combo.W:slider("wMana", "Mana %", 0, 1, 100, 1);

menu.Combo:menu("E", "KogMaw [E]");
menu.Combo.E:boolean("useE", "Use E In Combo", true);
menu.Combo.E:slider("eMana", "Mana %", 0, 1, 100, 1);

menu.Combo:menu("R", "KogMaw [R]");
menu.Combo.R:boolean("useR", "Use R In Combo", true);
menu.Combo.R:slider("rHealth", "Under Health %", 0, 1, 100, 1);
menu.Combo.R:slider("rStacks", "MaxStacks ", 1, 1, 9, 1);
menu.Combo.R:boolean("OnlyRange", "Use Only When Not In Range", true);

menu.Combo:menu("Misc", "Misc");
menu.Combo.Misc:boolean("saveWMana", "Save Mana For W", true);



menu:menu("Drawings", "Drawings");
menu.Drawings:boolean("rDamage", "Show How Many Ultimates To Kill", true);
menu.Drawings:boolean("qDraw", "Draw Q Range", true);
menu.Drawings:boolean("wDraw", "Draw W Range", true);
menu.Drawings:boolean("eDraw", "Draw E Range", true);
menu.Drawings:boolean("rDraw", "Draw R Range", true);

return menu