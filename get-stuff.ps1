function get-stuff {
[cmdletBinding()]
param()

    #get some data
    $data = invoke-restMethod -Method Get -uri "https://jsonplaceholder.typicode.com/albums"
    #loop around data and classify as Special if conditions are met
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
            #I want to break out of this foreach loop if it finds the first instance of a special title
            #but this also causes the loop in get-stuff to terminate and not return any data.
            break
        }
    })
    $IsSpecial
}