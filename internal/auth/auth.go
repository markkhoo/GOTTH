package auth

import (
	db "goth/internal/db/go"

	"github.com/golang-jwt/jwt"
)

type TokenAuth interface {
	GenerateToken(user db.User) (string, error)
	ValidateToken(tokenString string) (jwt.MapClaims, error)
}
