'Starting'

function Test-Function {
    $fishtank = 1..10

    Foreach ($fish in $fishtank)
    {
        if ($fish -eq 7)
        {
            #break      # <- abort loop
            #continue  # <- skip just this iteration, but continue loop
            return    # <- abort code, and continue in caller scope
            #exit      # <- abort code at caller scope 
        }

        "fishing fish #$fish"

    }
    'Done.'
}

Test-Function


'Script done!'