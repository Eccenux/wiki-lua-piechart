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
		src: 'tpl.Piechart.pl.css',	// pl without pp-template
		dst: 'Template:Pie chart/sandbox/styles.css',
		site,
	}));
	// configs.push(new DeployConfig({
	// 	src: 'tpl.Piechart.en.mediawiki',
	// 	dst: 'Template:Pie chart/sandbox',
	// 	site,
	// }));
	configs.push(new DeployConfig({
		src: 'Piechart.lua',
		dst: 'Module:Piechart/sandbox',
		site,
	}));

	// deploy
	await ployBot.deploy(configs);

})().catch(err => {
	console.error(err);
	process.exit(1);
});
