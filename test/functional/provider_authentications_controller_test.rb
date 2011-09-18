require 'test_helper'

class ProviderAuthenticationsControllerTest < ActionController::TestCase
  setup do
    @provider_authentication = provider_authentications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:provider_authentications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create provider_authentication" do
    assert_difference('ProviderAuthentication.count') do
      post :create, :provider_authentication => @provider_authentication.attributes
    end

    assert_redirected_to provider_authentication_path(assigns(:provider_authentication))
  end

  test "should show provider_authentication" do
    get :show, :id => @provider_authentication.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @provider_authentication.to_param
    assert_response :success
  end

  test "should update provider_authentication" do
    put :update, :id => @provider_authentication.to_param, :provider_authentication => @provider_authentication.attributes
    assert_redirected_to provider_authentication_path(assigns(:provider_authentication))
  end

  test "should destroy provider_authentication" do
    assert_difference('ProviderAuthentication.count', -1) do
      delete :destroy, :id => @provider_authentication.to_param
    end

    assert_redirected_to provider_authentications_path
  end
end
