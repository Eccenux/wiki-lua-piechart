import { Wikiploy, setupSummary, DeployConfig } from 'wikiploy';

import * as botpass from './bot.config.mjs';
const ployBot = new Wikiploy(botpass);

// run asynchronously to be able to wait for results
(async () => {
	// custom summary from a prompt
	await setupSummary(ployBot);

	// push out file(s) to wiki
	const configs = [];
	
	let site = 'en.wikipedia.org';
	configs.push(new DeployConfig({
		src: 'tpl.Piechart.en.css',
		dst: 'Template:Pie chart/styles.css',
		site,
	}));
	configs.push(new DeployConfig({
		src: 'Piechart.lua',
		dst: 'Module:Piechart',
		site,
	}));

	site = 'pl.wikipedia.org';
	configs.push(new DeployConfig({
		src: 'tpl.Piechart.pl.css',
		dst: 'Template:Piechart/style.css',
		site,
	}));
	configs.push(new DeployConfig({
		src: 'Piechart.lua',
		dst: 'Module:Piechart',
		site,
	}));

	// deploy
	await ployBot.deploy(configs);

})().catch(err => {
	console.error(err);
	process.exit(1);
});
