<#
    .SYNOPSIS
    This script find the synonyms of all created string permutations
    for given the number.

    .DESCRIPTION
    This script is designed to pick the given number of alphabets randomly
    and generates all possible string permutations or cominations and
    find the synonyms for the formed meaningful words.

    Eg., If number 3 is entered and the script has picked abc randomly
    from the alphabets library then it forms words combinations like
    abc/acb/bac/bca/cab/cba and finds the synonyms for these words.

    .NOTES
    Author						Version			Date			Notes
    --------------------------------------------------------------------------------------------------------------------
    harish.b.karthic		    v1.0			02/01/2020		Initial script and commit
    harish.b.karthic		    v1.1			02/01/2020		Added Synonyms functions
    harish.b.karthic		    v1.2			03/01/2020		Minor changes
    harish.b.karthic		    v1.3			03/01/2020		Added help content


#>

# function to pick random letters from alphabet library
Function Get-Alphabets($Number){

    $counter = 1
    $Word = ""

    While($counter -le $Number) { 
        $counter = $counter+1
        $Word += Get-Random $AlphabetsLibrary
    }
    return $Word
}

# Find number of possible words combination
Function Find-Combinations($newword) {
    
    $Length = 1..$newword.Length
    $Factorial = 1
    $Length | ForEach-Object {
        $Factorial *= $_
    }
    return $Factorial
}

# Find repeated letters in newly formed word
Function Find-RepeatedLetters($repeatedword) {

    $FinalWord = ""
    $repeatedword = ($repeatedword.ToCharArray() | Group-Object -NoElement).Name

    foreach($letter in $repeatedword) {
        $FinalWord += $letter
    }
    return $FinalWord
}

# Find string permutations
Function Find-StringPermutations($PermutationWord) {
    if ($PermutationWord.Length -eq 0) {
        return ""
    }

    elseif ($PermutationWord.Length -eq 1) {
        return $PermutationWord
    }

    else {
        $PermWord = @()
        $counter = $PermutationWord.Length
    
        for($i=0;$i -lt $PermutationWord.Length;$i++) {
            $FirstLetter = $PermutationWord[$i]
            $RemainingLetters = $PermutationWord.Substring(0,$i) + $PermutationWord.Substring(($i+1),($counter-1))
            $counter -= 1

            foreach($letter in Find-StringPermutations($RemainingLetters)) {
                $PermWord += $FirstLetter + $letter
            }          
        }
        return $PermWord
    }
}

# Function to get the synonyms of generated words
Function Get-Synonyms($Words) {

    $result = @()

    foreach($Word in $Words) {
    
        try {
            $WebRequest = Invoke-WebRequest -Uri "https://www.synonym.com/synonyms/$($Word)"

            $Synonyms = ($WebRequest.ParsedHtml.IHTMLDocument2_body.getElementsByClassName("card-content") `
            | Select-Object innerText -First 2 -ExpandProperty innerText)[1]
            $Synonyms = $Synonyms.Replace("  ",",").TrimEnd(",") -split ","

            $Hash = [PSCustomObject]@{
                "Words" = $Word
                "Synonyms" = $Synonyms
            }
            $result += $Hash
        }
        catch {
            $Hash = [PSCustomObject]@{
                "Words" = $Word
                "Synonyms" = "No synonym for the word!"
            }
            $result += $Hash
        }
    }
        return $result
}

# region Execute Functions

# Create alphabets library (Global variables)
$Alphabets = [Char[]](97..122)
$AlphabetsLibrary = @()

For($i=0; $i -lt $Alphabets.Count; $i++) {
    $AlphabetsLibrary += $Alphabets[$i]
}

# User input : Get the number of lettrs to be picked
$Number = Read-Host "Enter the number of Alphabets to be picked "

# Pick the random alphabets from alphabets library
$newword = Get-Alphabets -Number $Number

# Find possible number of combinations from picked letters/word
$Combinations = Find-Combinations -newword $newword
Write-Host "Possible number of Combinations from the formed word $($newword) is $($Combinations)" -ForeGroundColor Green

# Find the repeated letters in the formed word and select only unique letters in the word
$FinalWord = Find-RepeatedLetters -repeatedword $newword

# Find all possible combinations of letters in the word
$AllCombinations = Find-StringPermutations -PermutationWord $FinalWord
Write-Host "The combinations are : $($AllCombinations -join ",")" -ForegroundColor Green

#Find Synonyms for all words generated
Get-Synonyms -Words $AllCombinations

# endregion Execute Functions