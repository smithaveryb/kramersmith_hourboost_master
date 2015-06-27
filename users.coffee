jf = require 'jsonfile'
chalk = require 'chalk'
inquirer = require 'inquirer'
Steam = require 'steam'

POSSIBLE_GAMES = [
  {name: 'CS 1.6', value: '10', checked: true}
  {name: 'CS Source', value: '240', checked: true}
  {name: 'CS GO', value: '730', checked: true}
  {name: 'Dota 2', value: '570'}
  {name: 'TF2', value: '440', checked: true}
  {name: 'GTAV', value: '271590'}
  {name: 'DayZ', value: '221100'}
  {name: 'H1Z1', value: '295110'}
  {name: 'CivV', value: '8930'}
  {name: 'Infestation: SS', value: '226700'}
  {name: 'Binding Isaac Rebirth', value: '250900'}
  {name: 'Borderlands 2', value: '49520'}
  {name: 'Garrys mod', value: '4000'}
  {name: 'Half-life', value: '70'}
  
]

account = null

class SteamAccount
  accountName: null
  password: null
  authCode: null
  shaSentryfile: null
  games: []

  constructor: (@accountName, @password, @games) ->
    @steamClient = new Steam.SteamClient
    @steamClient.on 'loggedOn', @onLogin
    @steamClient.on 'sentry', @onSentry
    @steamClient.on 'error', @onError

  testLogin: (authCode=null) =>
    @steamClient.logOn
      accountName: @accountName,
      password: @password,
      authCode: authCode,
      shaSentryfile: @shaSentryfile

  onSentry: (sentryHash) =>
    @shaSentryfile = sentryHash.toString('base64')

  onLogin: =>
    console.log(chalk.green.bold('✔ ') + chalk.white("Sucessfully logged into '#{@accountName}'"))
    setTimeout =>
      database.push {@accountName, @password, @games, @shaSentryfile}
      jf.writeFileSync('db.json', database)
      process.exit(0)
    , 1500

  onError: (e) =>
    if e.eresult == Steam.EResult.InvalidPassword
      console.log(chalk.bold.red("X ") + chalk.white("Logon failed for account '#{@accountName}' - invalid password"))
    else if e.eresult == Steam.EResult.AlreadyLoggedInElsewhere
      console.log(chalk.bold.red("X ") + chalk.white("Logon failed for account '#{@accountName}' - already logged in elsewhere"))
    else if e.eresult == Steam.EResult.AccountLogonDenied
      query = {type: 'input', name: 'steamguard', message: 'Please enter steamguard code: '}
      inquirer.prompt query, ({steamguard}) =>
        @testLogin(steamguard)

# Load database
try
  database = jf.readFileSync('db.json')
catch e
  database = []

query = [
  {type: 'input', name: 'u_name', message: 'Enter login name: '}
  {type: 'password', name: 'u_password', message: 'Enter password: '}
  {type: 'checkbox', name: 'u_games', message: 'Please select games to be boosted: ', choices: POSSIBLE_GAMES}
]

inquirer.prompt query, (answers) ->
  account = new SteamAccount(answers.u_name, answers.u_password, answers.u_games)
  account.testLogin()
