function get-stuff {
[cmdletBinding()]
param()

    #get some data
    $data = invoke-restMethod -Method Get -uri "https://jsonplaceholder.typicode.com/albums"
    $Result = $Data.foreach({
        $Album = $_
        $Special = test-stuff -album $Album
        $out = [psCustomObject]@{
            Title = $Album.Title
            Special = $Special
        }
        $out
    })
    $Result
}

function test-stuff {
[cmdletBinding()]
param(
[Parameter(Mandatory)]
[PSCustomObject]$Album
)

    $IsSpecial = $false
    $SpecialWords = @("squid","octopus","rerum","junk","cat","whatever","something","fish")
    $SpecialWords.foreach({
        if ($Album.Title -like "voluptas $($_)*") {
            $IsSpecial = $true
            break
        }
    })
    $IsSpecial
}