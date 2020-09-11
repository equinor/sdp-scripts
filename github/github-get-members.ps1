## Per September 2020, Github API does not provide a direct API to list "SAML unlinked" members. Only all members, and linked members. The diff between thoes should re-create the list of unlinked members.
## Github also doesn't enforce users to put their Equinor email, so creating a mailing list for those users will need another lookup.

$url = "https://api.github.com/graphql"

if ($env:github_token)
{
    $token = $env:github_token
}
else {
    Write-Host "You must set the 'github_token' env variable!" -ForegroundColor Red
    Exit
}


$offset = ""

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("content-type","application/json")
$headers.Add("Authorization","bearer $token")

$bodyA = '{"query":"query { organization(login: \"Equinor\"){ membersWithRole(first: 100) { edges { node {name, login} } pageInfo {endCursor, hasNextPage} } } }"}'
$bodyB = '{"query":"query { organization(login: \"Equinor\") { samlIdentityProvider { ssoUrl, externalIdentities(first: 100) { edges { node { samlIdentity {nameId}, user {name, login} } } pageInfo {endCursor, hasNextPage}  } } } }"}'


$response = Invoke-WebRequest -Uri $url -Method Post -Body $bodyB -Headers $headers
Write-host $response.Content

echo  $response.Content
