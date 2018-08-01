package main

import (
	"flag"
	"fmt"
	"os"
	"testing"

	ca "github.com/juamedgod/cliassert"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"golang.org/x/crypto/bcrypt"
)

func Test_main(t *testing.T) {
	for _, tt := range tests {

		t.Run(tt.name, func(t *testing.T) {
			expectedCost := DefaultCost
			args := []string{}
			if tt.cost != 0 {
				expectedCost = tt.cost
				args = append(args, fmt.Sprintf("--cost=%d", tt.cost))
			}
			res := runTool(os.Args[0], args, tt.password)

			if tt.wantErr {
				if res.Success() {
					t.Errorf("the command was expected to fail but succeeded")
				} else if tt.expectedErr != nil {
					res.AssertErrorMatch(t, tt.expectedErr)
				}
			} else {
				if !res.Success() {
					t.Errorf("the command was expected to success but failed with %q", res.Stderr())
				} else {
					stdout := []byte(res.Stdout())
					require.NoError(t, bcrypt.CompareHashAndPassword(stdout, []byte(tt.password)))
					c, err := bcrypt.Cost(stdout)
					require.NoError(t, err)
					assert.Equal(t, c, expectedCost)
				}
			}
		})
	}
}

func TestMain(m *testing.M) {
	if os.Getenv("BE_TOOL") == "1" {
		main()
		os.Exit(0)
		return
	}
	flag.Parse()
	c := m.Run()
	os.Exit(c)
}

func runTool(bin string, args []string, stdin string) ca.CmdResult {
	cmd := ca.NewCommand()
	if stdin != "" {
		cmd.SetStdin(stdin)
	}
	os.Setenv("BE_TOOL", "1")
	defer os.Unsetenv("BE_TOOL")
	return cmd.Exec(bin, args...)
}

func RunTool(args ...string) ca.CmdResult {
	return runTool(os.Args[0], args, "")
}
